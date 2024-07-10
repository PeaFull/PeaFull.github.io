---
title: react如何在组件外部调用组件内的方法
date: 2018-07-04 16:20:34
categories: 编程
tags: React
---
#### 在开发中，难免会遇到这种场景：我们需要在组件外部调用组件内的方法，从而达到在外部操作组件或者获取组件内部数据的目的。
#### 示例代码如下：
<!--more-->
```TypeScript
import * as React from "react";

//外层组件
export class Parent extends React.Component<{}, {}> {
    //用一个变量接收子组件的this
    public child: any;
    constructor() {
        super();
    }

    //绑定子组件的this到this.child
    bindChild = (ref:any) => {
        this.child = ref;
    }

    //用于调用子组件的方法
    click = (e) => {
        this.child.myName()
    }

    public render() {
        return <div>
            <Child bindChild={this.bindChild} />
            <button onClick={this.click} >getName</button>
        </div>
    }
}

//子组件
interface ChildOwnProps {
    bindChild: Function;//提供一个属性，用于把this传递给外部组件
}

class Child extends React.Component<ChildOwnProps> {
    constructor(props:ChildOwnProps) {
        super(props);
    }

    componentDidMount(){
        //传递this
        this.props.bindChild(this);
    }

    //供外部调用的方法
    myName = () => alert('xiaohesong')

    render() {
        return <div>child</div>
    }
}

```
#### 其实原理很简单，即子组件向外提供一个属性，用于把自己的this传递给外部组件，外部组件用一个变量接收子组件传递过来的this之后就可以随意调用子组件内部的方法。
