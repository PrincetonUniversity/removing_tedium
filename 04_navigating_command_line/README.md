# Navigating and Editing the Command Line

On this page we present the essential keyboard shortcuts and concepts for working efficiently on the command line. For a complete guide see the [GNU readline](https://tiswww.case.edu/php/chet/readline/readline.html) documentation.

## Keyboard shortcuts

```
[Ctrl] + [a]   # move cursor to beginning of line (think: the beginning letter of the alphabet is 'a')
[Ctrl] + [e]   # move cursor to end of line (think: 'e' stands for 'end')
[Ctrl] + [u]   # delete from cursor to beginning of line
[Ctrl] + [k]   # delete from cursor to end of line
[Ctrl] + [w]   # delete the last word
Up arrow       # cycle backward through your history
Down arrow     # cycle forward through your history
```

Exercise: Paste the line below on to the command line and try out the sequences above:

```
squeue --start --format="%.7i %.7Q %.14q %6P %.15j %.12u %.10a %.20S %.6D %.5C %R" --sort=S --states=PENDING | egrep -v "N/A" | head -20
```

How do you move the cursor to the middle of the line? You may be able to use `[meta] + [f]` and `[meta] + [b]` to advance forward and backward by words, respectively. What is the `[meta]` key for your system? On Mac is it the `[option]` key. On Mac with Terminal, try holding down the `[option]` key and click with the mouse where you want the cursor to go on the command line.

## Tab completion

The `[tab]` key can be used to autocomplete the command. Most everyone is aware of this but not everyone uses it. Train yourself to use tab completion whenever possible.

## Changing to the previous working directory

Use the following command to return to the previous working directory:

```
$ cd -
```

Here is a sample session:

```
$ pwd
/home/aturing/work
$ cd /tigress/aturing/crypto/research
$ pwd
/tigress/aturing/crypto/research
$ cd -
$ pwd
/home/aturing/work
```

See `pushd`, `popd` and `dirs` for a more general approach for returning to previous locations.

## Running a previous command

Rerun the most recent `<command>` in your history with `!<command>`. Here is an example:

```
$ python myscripty.py
$ ll
$ date
$ !p
python myscript.py
$
```

`!p` finds the first command in your history that begins with the letter 'p' and runs it. One could have also used `!python`. See the next section for a modern alternative to `!<command>`.

## Search and run (or modify) a previous command

Hold down `[Ctrl]` and press `[r]` to invoke "reverse-i-search." Then type a letter like 'p' and you will get a match for the most recent command in your history that contains 'p'. Keep typing to narrow your search. When you find the desired command, press `[Enter]` to execute. Or hit one of the side arrow keys to modify the command before running it. Or press `[Ctrl]+[r]` to advance to the next match. You can cancel by running either `[Ctrl]+[g]` or `[Ctrl]+[c]`.

## A general note on text editors

Be sure to explore the shortcuts offered by your text editor. Editors like `vim` and `emacs` cannot be mastered in only a few hours. Make sure that you are taking advantage of these tools. To test your `vim` knowledge, run this command: `vimtutor`. To improve your `vim` skills see [Intermediate vim](https://github.com/troycomi/intermediate-vim) by T. Comi of Princeton.

## Keyboard customizations

See [this workshop](https://github.com/jdh4/mac_productivity) for using Raycast (and maybe for Mac users [Karabiner-Elements](https://karabiner-elements.pqrs.org)).

## Fix command (fc)

This command is useful when you enter a long command that has a mistake. Run `fc` and that command will be loaded in a text editor where you can make corrections. The command is executed upon exiting the editor. Note that you can also intentionally enter a wrong command so that you can use a text editor to make changes to the command and use the search functionality of the editor to advance to the middle of the line.

To set your text editor of choice, set the following in your `~/.bashrc` file:

```
export EDITOR=/usr/bin/vim   # or emacs or nano
```

## Programmable keyboards

A programmable keyboard provides extras keys that can be mapped to various custom functions. There are also pseudo-versions
that try to enhance standard keyboards via software and provide lots of additional features. For Windows see [AutoHotKey](https://www.autohotkey.com/) and for Mac see [Keyboard Maestro](https://www.keyboardmaestro.com/main/).

## Useful links

[Level Up Your Command Line](https://github.com/PrincetonUniversity/advanced-command-line) by T. Comi of Princeton  
[Linux Productivity Tools](https://www.olcf.ornl.gov/wp-content/uploads/2019/12/LPT_OLCF.pdf) by ORNL  
[Advanced UNIX & Shell Computing](https://www.olcf.ornl.gov/wp-content/uploads/2018/07/Intro_to_Unix_2018.pdf) by ORNL
