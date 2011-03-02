#!/usr/bin/ruby
# encoding: utf-8
# (c) 2011 Martin Kozák (martinkozak@martinkozak.net)

require "frozen-objects"
require "bit-packer"

##
# StructFx builder and analyzer.
#

class StructFx
    
    ##
    # Holds resultant data structure.
    #
    
    @struct

    ##
    # Holds type stack.
    #
    
    @stack
    
    ##
    # Holds data.
    #
    
    @data
    
    ##
    # Holds raw data.
    # @return [String] raw (original) string data
    #
    
    attr_reader :raw
    @raw
    
    ##
    # Holds stack in compiled form.
    #

    @compiled
    
    ##
    # Holds types metainformations map.
    #
    
    TYPES = Frozen << {
        :int8 => ["c", 1],
        :int16 => ["s", 2],
        :int32 => ["l", 4],
        :int64 => ["q", 8],
        :uint8 => ["C", 1],
        :uint16 => ["S", 2],
        :uint32 => ["L", 4],
        :uint64 => ["Q", 8],
        :float => ["f", 4],
        :double => ["d", 8],
        :char => ["a", 1],
        :string => ["Z", 1],
        :byte => ["C", 1],
        :skip => ["a", 1],
    }
    
    ##
    # Holds compiled form structure.
    #
    
    Compiled = Struct::new(
        :enabled, :processors, :packing, :unpacking, :lengths, :length
    )
    
    ##
    # Constructor.
    #
    # @param [String] data raw string for unpack
    # @param [Proc] block block with declaration
    # @see #declare
    #
    
    def initialize(data = nil, &block)
        @stack = [ ]
        self.declare(&block)
        
        if not data.nil?
            self << data
        end
    end
    
    ##
    # Receives declaration.
    # 
    # Adds declaration of bit array items. Can be call multiple times.
    # New delcarations are joind to end of the array.
    #
    # @example
    #   struct = StructFx::new("abcdefghijklmnopqrstuvwxyz0123456789ABCDEFGHIJKLMOPQRSTUVWXYZ") do
    #       int8 :n_int8
    #       int16 :n_int16
    #       int32 :n_int32
    #       int64 :n_int64
    #       uint8 :n_uint8
    #       uint16 :n_uint16
    #       uint32 :n_uint32
    #       uint64 :n_uint64
    #       float :n_float
    #       double :n_double
    #       char :n_char
    #       string (:n_string) {3}
    #       byte :n_flags do  # byte is usually length 8 bits
    #           number (:n_number) {7}
    #           boolean :n_boolean
    #       end
    #   end
    #
    # @param [Proc] block block with declaration
    # @see TYPES
    #

    def declare(&block)
        self.instance_eval(&block)
    end

    ##
    # Handles missing methods as declarations.
    #
    # @param [Symbol] name data type of the entry
    # @param [Array] args first argument is expected to be name
    # @param [Proc] block block which returns length of the entry in bits
    # @return [Integer] new length of the packed data
    # @see #declare
    #
    
    def method_missing(name, *args, &block)
        if self.class::TYPES.include? name
            self.add(args.shift, name, nil, block)
        else
            raise Exception::new("Invalid type/method specified: '" << name.to_s << "'")
        end
    end
    
    ##
    # Returns compiled form.
    # @return [Class] compiled form struct
    #
    
    def compiled
        if @compiled.nil?
            @compiled = self.class::Compiled::new([], [], "", "", [], 0)
            types = self.class::TYPES
            
            @stack.each do |name, type, args, block|
                type_meta = types[type]
                length = block.nil? ? 1 : block.call()
                pack_char = type_meta[0] + length.to_s
                total_length = type_meta[1] * length
                
                @compiled.enabled << (not name.nil?)
                @compiled.processors << args
                @compiled.packing << pack_char
                @compiled.unpacking << pack_char
                @compiled.lengths << total_length
                @compiled.length += total_length
            end
            
        end
        
        @compiled.enabled.freeze
        @compiled.processors.freeze
        @compiled.packing.freeze
        @compiled.unpacking.freeze
        @compiled.lengths.freeze

        return @compiled.freeze
    end
    
    ##
    # Adds byte BitPacker declaration.
    #
    # @param [Symbol] name name of the entry
    # @param [Proc] block declaration
    # @see
    #
    
    def byte(name, &block)
        callback = Proc::new do |value|
            BitPacker::new(value, &block)
        end
        
        self.add(name, :byte, callback)
    end
    
    ##
    # Adds skipping declaration.
    # @param [Proc] block with length
    #
    
    def skip(&block)
        self.add(nil, :skip, nil, block)
    end
    
    ##
    # Fills by input data.
    # @param [Integer] value raw integer data for unpack
    #
    
    def <<(value)
        if value.bytesize < self.compiled.length
            raise Exception::new("Data are shorter than declaration.")
        end
        
        @raw = value.to_s
        @data = nil
    end
    
    ##
    # Adds declaration.
    #
    # @param [Symbol] name name of the entry
    # @param [Symbol] type type of the entry
    # @param [Proc] callback postprocessing callback
    # @param [Proc] block length declaration block
    # 

    def add(name, type, callback = nil, block = nil)
        @stack << [name, type, callback, block]
        @struct = nil
        @compiled = nil
    end
    
    ##
    # Returns structure analyze.
    # @return [Class] struct with the packed data
    #
    
    def data
        if @data.nil?
            values = [ ]
            compiled = self.compiled
            extracted = @raw.unpack(compiled.unpacking)

            compiled.enabled.each_index do |i|
            
                # Skips skipped items
                if not compiled.enabled[i]
                    next
                end
                
                # Calls postprocessing if required
                callback = compiled.processors[i]
                if callback.nil?
                    values << extracted[i]
                else
                    values << callback.call(extracted[i])
                end
                
            end

            @data = __struct::new(*values)
        end
        
        return @data
    end
    
    ##
    # Returns total length of the struct in bytes.
    # @return [Integer] total length of the declaration
    #
    
    def length
        self.compiled.length
    end
    
    ##
    # Converts to string.
    # @return [String] resultant string according to current data state
    #
    
    def to_s
        entries = self.data.entries
        compiled = self.compiled
        
        values = [ ]
        length = 0
        delta = 0
        
        compiled.enabled.each_index do |i|
        
            # Pastes skipped data from RAW
            if not compiled.enabled[i]
                from = length
                to = (length + compiled.lengths[i])
                values << @raw[from...to]
                delta += 1
            
            # In otherwise, take value from analyzed data
            else
                values << entries[i - delta]    # current item minus count of non-entry (skipped) items
            end
        
            length += self.compiled.lengths[i]
        end

        values.pack(self.compiled.packing)
    end
    
    
    protected 
      
    ##
    # Returns data struct.
    #

    def __struct
        if @struct.nil?
            members = @stack.map { |i| i[0] }
            members.compact!

            @struct = Struct::new(*members)
        end
        
        return @struct
    end

end
