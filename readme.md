# git-change-author

## What does this script do ?
The purpose of this script is that change the values of
- ***committer email***
- ***committer name***
- ***author email***
- ***author name***

of all commits from all branches<br>
without changing commit time.

This script is for local side that modified from [github example](https://help.github.com/en/articles/changing-author-info)
which is for remote side rather then local side.

After running this script, you only change local git history.<br>
You have to update to remote(e.g., github) by youself by using force update(git push -f) to overwrite remote git history.

## When to use ?
When you make a new github account and want to move repos from old account to new one,<br>
you may want that the commits of your repos display new github id and new email rather than old ones.


## Why to use ?
It is useful and more efficient than below method.
- [stackoverflow - How to change the commit author for one specific commit?](https://stackoverflow.com/questions/3042437/how-to-change-the-commit-author-for-one-specific-commit)
- [Git: Change author of a commit](https://makandracards.com/makandra/1717-git-change-author-of-a-commit)


## Usage
```bash

bash <(curl -s https://raw.githubusercontent.com/h1karxii/git-change-author/master/git_change_author.sh) \
-o old@email.com -n new@email.com -u newusername

```


## Warning
The action of this script is **IRREVERSIBLE**!!!<br>
Because of that it's necessary to get rid of anything that has a pointer to those old commits before you repack,<br>
your reflog and a new set of refs (**.git/refs/original/refs/heads**) will be cleared by this script.<br>
Just make sure that you are really know about what you are doing.


## Reference
[Github - Changing author info](https://help.github.com/en/articles/changing-author-info)

[Git Internals - Maintenance and Data Recovery](https://git-scm.com/book/en/v2/Git-Internals-Maintenance-and-Data-Recovery) ([chinese version](https://git-scm.com/book/zh-tw/v1/Git-%E5%85%A7%E9%83%A8%E5%8E%9F%E7%90%86-%E7%B6%AD%E8%AD%B7%E5%8F%8A%E8%B3%87%E6%96%99%E5%BE%A9%E5%8E%9F))

[【冷知識】怎麼樣把檔案真正的從 Git 裡移掉？](https://gitbook.tw/chapters/faq/remove-files-from-git.html)