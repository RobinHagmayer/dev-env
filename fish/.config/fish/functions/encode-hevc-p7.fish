function encode-hevc-p7
    # Usage info
    if test (count $argv) -lt 2
        echo "Usage: encode-hevc-p7 <inputfile> [options] <outputfile>"
        echo "Options:"
        echo "  -r N    set output framerate (default: keep source)"
        echo "  -cq N   set NVENC constant quality (default: 28)"
        echo "  -f      apply filters: atadenoise,deband,pp=de"
        return 1
    end

    # Defaults
    set fps ""        # empty = keep source fps
    set cq 28         # default quality value
    set use_filters 0

    # First arg = input file, last arg = output file
    set in_file $argv[1]
    set out_file $argv[-1]

    # Parse args between input and output
    set i 2
    while test $i -lt (count $argv)
        set arg $argv[$i]
        switch $arg
            case -r
                set i (math $i + 1)
                set fps $argv[$i]
            case -cq
                set i (math $i + 1)
                set cq $argv[$i]
            case -f
                set use_filters 1
        end
        set i (math $i + 1)
    end

    # Build ffmpeg command
    set cmd "ffmpeg -i \"$in_file\""
    if test -n "$fps"
        set cmd "$cmd -r $fps"
    end
    if test $use_filters -eq 1
        echo "▶ Encoding with filters"
        set cmd "$cmd -vf atadenoise,deband,pp=de"
    else
        echo "▶ Encoding without filters"
    end

    set cmd "$cmd -c:v hevc_nvenc -preset p7 -rc vbr -cq $cq -c:a copy \"$out_file\""
    eval $cmd
end
