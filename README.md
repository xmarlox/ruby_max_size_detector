# Ruby Max Size Detector

This gem allows you to analyze an input file (contains several terminal commands and output related to files and directories) and finally detect all directories candidate for deletion based on the maximum size.


## INSTALLATION

```
gem install -N max_size_detector
```


## USAGE

```
max_size_detector
```

You may also specify the input file
```
max_size_detector sample_input.txt 
```

And also the maximum size (unformatted and/or plain number)
```
max_size_detector input.txt 10000
```


### REFERENCE

* [Rationale](https://gist.github.com/ronakjain90/3dcfef6a752f77b3e8202ad9844195ae)


### CREDITS

Grateful to [99minds](https://99minds.io/) for this opportunity :bow:
