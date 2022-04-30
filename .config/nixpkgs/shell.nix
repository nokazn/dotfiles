{}:

{
  init = ''

# common settings ----------------------------------------------------------------------------------------------------
if [ -f ~/.shrc.sh ]; then
    source ~/.shrc.sh
else
    echo "⚠ ~/.shrc.sh doesn't exist"
fi
  '';

  profile = ''

# common settings ----------------------------------------------------------------------------------------------------
if [[ -f ~/.sh_profile.sh ]]; then
    source ~/.sh_profile.sh
else
    echo "⚠ ~/.sh_profile.sh doesn't exist"
fi
  '';
}
