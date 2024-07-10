---
title: React的Ref属性在TypeScript中的写法
date: 2018-05-04 12:05:11
categories: 编程
tags: React
---


#### 在TypeScript中使用ref属性的时候，如果不定义它的类型直接去使用this.refs.XXX，就会在编译的时候报错。参考如下代码：

<!--more-->
```TypeScript
import * as React from "react";

export class CustomTextInput extends React.Component<{}, {}> {

    //在此处统一定义refs
    public refs: {
        textInput: HTMLInputElement,
        loadMoreDiv: HTMLElement
    };

    constructor() {
        super();
    }

    componentDidMount() {
        const loadMore = this.refs.loadMoreDiv;
        const myInput = this.refs.textInput;
    }

    public render() {
        return <div>
            <input type="text" ref= "textInput" />
            <div ref= "loadMoreDiv"></div>
        </div>;
    }
}
```
转自：[Strongly Typed React Refs with TypeScript][1]


  [1]: https://goenning.net/2016/11/02/strongly-typed-react-refs-with-typescript/
