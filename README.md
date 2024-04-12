# Autocorrect Git-User (pre-commit hook)

A pre-commit hook to set/correct the git user automatically based on a regex for the git remote url

## Installation

```
bash <(curl -s https://raw.githubusercontent.com/derhollaender/set-git-user-for-remote/main/install.sh)
```

## Why add this hook ?

Using this script provides the following benefits:

1. Automatic setting and **correcting** thegit user before each commit based on the git remote URL of the repository.
2. Easy management of multiple git user credentials per remote using the `git-users.json` file.


example contents of [git-users.json](https://github.com/derhollaender/set-git-user-for-remote/blob/main/gitusers.json.example)
```json
{
    "work": {
        "username": "John Doe @ facebook",
        "email": "john.doe@facebook.com",
        "remote_url_regex": "(git.facebook.com|git.facebook.org|git.meta.com)"
    },
    "gitlab": {
        "username": "John Doe",
        "email": "john.doe@gmail.com",
        "remote_url_regex": "gitlab\\.com"
    },
    "aws-alexa": {
        "username": "JD",
        "email": "john.doe@amazon.com",
        "remote_url_regex": "codecommit"
    },
    "github": {
        "username": "john-doe-the-coder",
        "email": "john.coder75@yahoo.com",
        "remote_url_regex": "github\\.com"
    },
    "bitbucket": {
        "username": "john-bb",
        "email": "john.coder75@yahoo.com",
        "remote_url_regex": "github\\.com"
    },
    "default": {
        "username": "John Doe",
        "email": "john.doe@gmail.com",
        "remote_url_regex": ""
    }
}
```
With the configuration above, before each commit, the hook will ensure that the author name and email are set to
- `John Doe @ facebook` and `john.doe@facebook.com` __IF__ the remote url of the repository matches the regex `(git.facebook.com|git.facebook.org|git.meta.com)`
- `John Doe` and `john.doe@gmail.com` __IF__ the remote url of the repository matches the regex `(gitlab\\.com)`
- `JD` and `john.doe@gmail.com` when the remote url of the repository matches the regex `(codecommit)`
- `john-doe-the-coder` and `john.coder75@yahoo.com` __IF__ the remote url of the repository matches the regex `(github\\.com)`
- `john-bb` and `john.coder75@yahoo.com` __IF__ the remote url of the repository matches the regex `(github\\.com)`
- `John Doe` and `john.doe@gmail.com` __IF__ none of the other regexes match

