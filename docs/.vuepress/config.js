module.exports = {
    base: '/lustack.github.io/',
    title: 'lustack 知识星球',
    description: '沉淀、分享、成长',
    configureWebpack: {
        resolve: {
            alias: {
                '@alias': '/'
            }
        }
    },
    themeConfig: {
        logo: '/assets/img/logo.jpg',
        displayAllHeaders: false, // 默认值：false
        search: true,
        searchMaxSuggestions: 20, // {text: '', link: ''}
        authorAvatar: '/img/head.png',
        lastUpdated: '更新时间', // string | boolean
        author: 'ShowLu',
        nav: [
            {
                text: '项目管理',
                items: [
                    {text: '版本控制工具', items: [{text: 'Git第一章', link: '/pm/git/Gitee.md'}]}
                ]
            },
            {
                text: '操作系统',
                items: [
                    {text: 'Linux基本操作', items: [{text: '第一章', link: '/opsystem/linux/01/01.md'}, {text: '第二章', link: '/opsystem/linux/02.md'}, {text: '第三章', link: '/opsystem/linux/shell/01.md'}]}
                ]
            },
            {
                text: 'Netty',
                items: [
                    {text: '基础篇(一)', link: '/netty/Netty学习笔记.md'}
                ]
            },
            {
                text: 'Java基础',
                items: [
                    {text: '设计模式', items: [{text: '重学设计模式', link: '/java/设计模式/重学设计模式.md'}]}
                ]
            },
            {
                text: '消息队列',
                items: [
                    {text: 'kafka', items: [{text: '基础篇', link: '/messagequeue/kafka/基础学习篇/基础学习篇.md'}, {text: '深入理解kafka核心设计与实践原理', link: '/messagequeue/kafka/基础学习篇/深入理解kafka核心设计与实践原理.md'}]}
                ]
            },
            {
                text: '数据库',
                items: [
                    {text: 'elasticsearch', items: [{text: 'elk', link: '/dataprocessing/elasticsearch/Logstash.md'}, {text: '基础篇(一)', link: '/dataprocessing/elasticsearch/基础篇(一).md'}, {text: '基础篇(二)', link: '/dataprocessing/elasticsearch/基础篇(二).md'}, {text: '碎片篇(一)', link: '/dataprocessing/elasticsearch/碎片篇(一).md'}]},
                    {text: 'mongodb', items: [{text: 'ChangeStream.1', link: '/dataprocessing/mongodb/ChangeStareamDemo.md'}, {text: 'ChangeStream.2', link: '/dataprocessing/mongodb/MongodbChangeStareamDemo.md'}]}
                ]
            }
        ],
        // 自动形成侧边导航
        sidebar: 'auto',
        markdown: {
            lineNumbers: true
        },
        // 假定是 GitHub. 同时也可以是一个完整的 GitLab URL
        // repo: 'https://github.com/ShowLuu/lustack.github.io',
        repo: 'https://gitee.com/Showluu',
        // 自定义仓库链接文字。默认从 `themeConfig.repo` 中自动推断为
        // "GitHub"/"GitLab"/"Bitbucket" 其中之一，或是 "Source"。
        repoLabel: '源码仓库',

        // 以下为可选的编辑链接选项

        // 假如你的文档仓库和项目本身不在一个仓库：
        // docsRepo: '/tree/deploy',
        // 假如文档不是放在仓库的根目录下：
        docsDir: 'docs',
        // 假如文档放在一个特定的分支下：
        docsBranch: 'main',
        // 默认是 false, 设置为 true 来启用
        editLinks: false,
        // 默认为 "Edit this page"
        editLinkText: '帮助我们改善此页面！'
    }
}

