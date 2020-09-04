# Navigating and Editing the Command Line

On this page we present the essential keyboard shortcuts and concepts for working efficiently on the command line. For a complete guide see the [GNU readline](https://tiswww.case.edu/php/chet/readline/readline.html) documentation.

## Keyboard shortcuts

```
[Ctrl] + [a]   # move cursor to beginning of line (think 'a' is the beginning letter of the alphabet)
[Ctrl] + [e]   # move cursor to end of line (think 'e' stands for 'end')
[Ctrl] + [u]   # delete from cursor to beginning of line
[Ctrl] + [k]   # delete from cursor to end of line
Up arrow       # cycle backward through your history
Down arrow     # cycle forward through your history
```

Exercise: Paste the line below on to the command line and try out the sequences above:

```
squeue --start --format="%.7i %.7Q %.14q %6P %.15j %.12u %.10a %.20S %.6D %.5C %R" --sort=S --states=PENDING | egrep -v "N/A" | head -20
```

How do you move the cursor to the middle of the line? On Mac with Terminal, hold down the `[option]` key and click with the mouse where you want the cursor to go. On other systems you can use `[meta] + [f]` and `[meta] + [b]` to advance forward and backward by words, respectively. What is the `[meta]` key for your system?

## Tab completion

The tab key can be used to autocomplete the command. Most everyone is aware of this but not everyone uses it. Train yourself to use tab completion whenever possible.

## A general note on text editors

Be sure to explore the shortcuts offered by your text editor. Editors like vim and emacs cannot be mastered in only a few hours. Make sure that you are taking advantage of these tools. To test your vim knowledge, run this command: `vimtutor`

## Fix command (fc)

This command is useful when you enter a long command that has a mistake. Run `fc` and that command will be loaded in a text editor where you can make corrections. The command is executed upon exiting the editor. Note that you can also intentionally enter a wrong command so that you can use a text editor to make changes to the command and use the search functionality of the editor to advance to the middle of the line.

To set your text editor of choice, set the following in your `~/.bashrc` file:

```
export EDITOR=/usr/bin/vim   # or emacs or nano
```

## Changing to the previous working directory

Use the following command to return to the previous working directory:

```
cd -
```

Here is a sample session:

```
$ pwd
/home/ceisgrub/work
$ cd /tigress/ceisgrub/plasma/proposal
$ pwd
/tigress/ceisgrub/plasma/proposal
$ cd -
$ pwd
/home/ceisgrub/work
```

## Keyboard remappings

Consider having the `[Caps Lock]` key remapped to the `[Esc]` key. This is especially useful for `vim` users. What other remapping can you make to improve productivity?

## Running a previous command

Rerun the most recent `<command>` in your history with `!<command>`. Here is an example:

```
$ ssh <NetID>@adroit.princeton.edu
$ ll
$ date
$ !ssh
```

See the next section for a modern alternative.

## Search and running a previous command

Hold down `[Ctrl]` and press `[r]` to invoke "reverse-i-search." Type a letter - like s - and you'll get a match for the most recent command in your history that starts with s. Keep typing to narrow your search. When you find the desired command, press `[Enter]` to execute.

## Programmable keyboards

A programmable keyboard provides extras keys that can be mapped to various custom functions. There are also pseudo-versions
that try to enhance standard keyboards via software and provide lots of additional features. For Windows see [AutoHotKey](https://www.autohotkey.com/) and for Mac see [Keyboard Maestro](https://www.keyboardmaestro.com/main/).
