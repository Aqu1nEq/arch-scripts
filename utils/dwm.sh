# needs work

mkdir -p ~/sources/suckless
cd ~/sources/suckless

git clone https://git.suckless.org/dwm
git clone https://git.suckless.org/dmenu
git clone https://git.suckless.org/st

cd ~/sources/suckless/dwm
make clean install

cd ~/sources/suckless/dmenu
make clean install

cd ~/sources/suckless/st
make clean install

cd ~

# Check if the file does not exist
if [ ! -f "~/.xinitrc" ]; then
    touch .xinitrc
else
    echo "File already exists"
fi

touch .xinitrc

sed -i '$a exec dwm ' ~/.xinitrc
