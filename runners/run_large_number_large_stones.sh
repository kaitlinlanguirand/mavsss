for file in *.clean;
    do
        cp $file file.nex;
        ~/projects/revbayes-v1.2.1/bin/rb ../../scripts/large_number_large_stones.Rev;
        cp -r ss100/file100000 ss100/100000$file.log;
    done

