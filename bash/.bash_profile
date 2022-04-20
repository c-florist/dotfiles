# Include .bashrc if the shell is interactive
if [ -r ~/.profile ]; 
    then . ~/.profile; 
fi
case "$-" in *i*) 
    if [ -r ~/.bashrc ]; 
        then . ~/.bashrc; 
    fi;; 
esac
