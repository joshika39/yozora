function source-all
    if test (count $argv) -ne 1
        echo "Usage: source-all <.env file>"
        return 1
    end

    set env_file $argv[1]

    if not test -f $env_file
        echo "File not found: $env_file"
        return 1
    end

    for line in (cat $env_file | grep -v '^#' | grep '=')
        set key (echo $line | cut -d '=' -f1)
        set value (echo $line | cut -d '=' -f2-)
        set -x $key $value
    end
end
