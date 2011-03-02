StructFx
========

**struct-fx** provides declarative pure Ruby equivalent of C++ structs.
Declarations are simple:

    gif = StructFx::new(data) do
        string (:format) {3}
        string (:version) {3}
        uint16 :width
        uint16 :height
    end

See whole real live example:

    require "struct-fx"

    # Read and analyze file
    
    File.open("./test.gif", "rb") do |io|
        data = io.read(10)
    end

    gif = StructFx::new(data) do
        string (:format) {3}
        string (:version) {3}
        uint16 :width
        uint16 :height
    end
    
    # Get results
    
    p gif.length        # declared struct length is really 10 bytes
    
    p gif.data.format   # "GIF"
    p gif.data.version  # "89a"
    p gif.data.width    # 32
    p gif.data.height   # 32    # it's square :-)
    
    # Change the values
    
    gif.data.version = "87a"
    gif.data.width = 128
    gif.data.height = 128
    
    gif.data.to_s       # "GIF87a\x80\x00\x80\x00"
    
Supported data types are:
    
 * signed and unsigned `integers` (1 to 8 bytes),
 * fixed-size `strings` (specified length),
 * `floats` and `doubles` (4 and 8 bytes),
 * single `chars` (1 byte),
 * `packed bytes` and `flag arrays` (1 byte),
 * skipped data blocks.
 
More detailed documentation is available in `StructFx#declare` method 
documentation and [documentation][2] of the [BitPacker][1] library.

Contributing
------------

1. Fork it.
2. Create a branch (`git checkout -b 20101220-my-change`).
3. Commit your changes (`git commit -am "Added something"`).
4. Push to the branch (`git push origin 20101220-my-change`).
5. Create an [Issue][3] with a link to your branch.
6. Enjoy a refreshing Diet Coke and wait.

Copyright
---------

Copyright &copy; 2011 [Martin Kozák][4]. See `LICENSE.txt` for
further details.

[1]: http://github.com/martinkozak/bit-packer
[2]: http://rubydoc.info/gems/bit-packer/0.1.0/frames
[3]: http://github.com/martinkozak/struct-fx/issues
[4]: http://www.martinkozak.net/
