#!/bin/bash
#set -eux

GLOBAL_GIT_HOOKS_DIR="${GLOBAL_GIT_HOOKS_DIR:-$HOME/.git-templates/hooks}"

read -p "Enter the global git hooks directory path [$GLOBAL_GIT_HOOKS_DIR]: " answer
GLOBAL_GIT_HOOKS_DIR="${answer:-$GLOBAL_GIT_HOOKS_DIR}"
echo "  Using $GLOBAL_GIT_HOOKS_DIR as global git hooks directory"

SET_GIT_USER_URL="https://raw.githubusercontent.com/derhollaender/set-git-user-for-remote/main/set-git-user"
DESTINATION_DIR="$GLOBAL_GIT_HOOKS_DIR/_set-git-user"

mkdir -p "$DESTINATION_DIR"

# Check the operating system
if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OS
    if ! curl -sSL "$SET_GIT_USER_URL" -o "$DESTINATION_DIR/set-git-user"; then
        echo "Failed to download set-git-user script using curl from $SET_GIT_USER_URL."
        exit 1
    fi
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # Linux
    if ! wget -q "$SET_GIT_USER_URL" -O "$DESTINATION_DIR/set-git-user"; then
        echo "Failed to download set-git-user script using wget from $SET_GIT_USER_URL."
        exit 1
    fi
else
    echo "Unsupported operating system: $OSTYPE"
    exit 1
fi

#cp set-git-user "$DESTINATION_DIR/set-git-user"

chmod +x "$DESTINATION_DIR/set-git-user"

# Add the set-git-user script to the pre-commit hook
if [[ ! -f "$GLOBAL_GIT_HOOKS_DIR/pre-commit" ]]; then
    echo ""
    echo "creating pre-commit hook in $GLOBAL_GIT_HOOKS_DIR"

    echo '#!/bin/bash' > "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo '# this is a wrapper for the set-git-user script so you add other scripts for the pre-commit hook if needed' >> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo 'GIT_HOOKS_DIR="$(dirname "$0")"' >> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo '$GIT_HOOKS_DIR/_set-git-user/set-git-user "$@"' >> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo '# Run local pre-commit hook if exists'>> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo 'if [ -e ./.git/hooks/pre-commit ]; then'>> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo '  ./.git/hooks/pre-commit "$@"'>> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo 'else'>> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo '  exit 0'>> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    echo 'fi' >> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    chmod +x "$GLOBAL_GIT_HOOKS_DIR/pre-commit"

else
    echo ""
    read -p "The pre-commit hook already exists. Do you want to add the set-git-user script? (y/n):$END " answer
    if [[ "$answer" == "y" ]]; then
        echo "  adding set-git-user script to $GLOBAL_GIT_HOOKS_DIR/pre-commit"
        echo 'GIT_HOOKS_DIR="$(dirname "$0")"' >> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
        echo '$GIT_HOOKS_DIR/_set-git-user/set-git-user "$@"' >> "$GLOBAL_GIT_HOOKS_DIR/pre-commit"
    else    
        echo ""
        echo "  The pre-commit hook was not modified."
        echo "  You can add the set-git-user script manually by adding the following line to the pre-commit hook:"
        echo '  GIT_HOOKS_DIR="$(dirname "$0")"'
        echo '  $GIT_HOOKS_DIR/_set-git-user/set-git-user "$@"'
    fi
fi

# creating default git-users.json file
if [[ ! -f "$GLOBAL_GIT_HOOKS_DIR/_set-git-user/git-users.json" ]]; then
    echo ""
    echo "adding default git user to $GLOBAL_GIT_HOOKS_DIR/_set-git-user/git-users.json: $(git config --global user.name) $(git config --global user.email)"
    echo "{\"default\":{\"username\": \"$(git config --global user.name)\",\"email\":\"$(git config --global user.email)\",\"remote_url_regex\":\"\"}}" | jq > "$GLOBAL_GIT_HOOKS_DIR/_set-git-user/git-users.json"
else
    echo ""
    read -p "The git-users.json file already exists. Do you want to overwrite it? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        echo "  overwriting $GLOBAL_GIT_HOOKS_DIR/_set-git-user/git-users.json with default user: $(git config --global user.name) $(git config --global user.email)"
        echo "{\"default\":{\"username\": \"$(git config --global user.name)\",\"email\":\"$(git config --global user.email)\",\"remote_url_regex\":\"\"}}" | jq > "$GLOBAL_GIT_HOOKS_DIR/_set-git-user/git-users.json"
    else    
        echo "  The git-users.json file was not modified."
        echo "  You can add the default user manually by adding the following content to the git-users.json file:"
        echo "  {\"default\":{\"username\": \"$(git config --global user.name)\",\"email\":\"$(git config --global user.email)\",\"remote_url_regex\":\"\"}}"
    fi
fi

# checking if gloibal core.hooksPath is set correct
HOOKSPATH=$(git config --global core.hooksPath)
if [[ "$HOOKSPATH" != "$GLOBAL_GIT_HOOKS_DIR" ]]; then
    echo ""
    read -p "The global core.hooksPath is set to $HOOKSPATH. Do you want to set it to $GLOBAL_GIT_HOOKS_DIR? (y/n): " answer
    if [[ "$answer" == "y" ]]; then
        echo "  setting global core.hooksPath to $GLOBAL_GIT_HOOKS_DIR"
        git config --global core.hooksPath "$GLOBAL_GIT_HOOKS_DIR"
    else
        echo "  The global core.hooksPath was not modified."
        echo "  You can set it manually by running the following command:$ENDCOLOR"
        echo "  git config --global core.hooksPath $GLOBAL_GIT_HOOKS_DIR"
    fi
fi

echo ""
echo "INSTALLATION COMPLETE!"
echo "  Your git user will be set automatically before each commit based on the remote url"
echo ""
echo "  To add more git user credentials per remote add them in the git-users.json file located at $GLOBAL_GIT_HOOKS_DIR/_set-git-user/git-users.json"
echo "  For examples have a look at https://github.com/derhollaender/set-git-user-for-remote/git-users.json.example"

exit 0