#### 简易的命令行入门教程

Git 全局设置:

```shell
git config --global user.name "张卢"
git config --global user.email "1309617271@qq.com"
```

创建 git 仓库:

```shell
mkdir qeq1313
cd qeq1313
git init
touch think.md
git add think.md
git commit -m "first commit"
git remote add origin https://gitee.com/ShowLuu/qeq1313.git
git push -u origin master
```

已有仓库

```shell
cd existing_git_repo
git remote add origin https://gitee.com/ShowLuu/qeq1313.git
git push -u origin master

git remote add origin https://gitee.com/ShowLuu/lu-cloud.git
git push -u origin develop
```

