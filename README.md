# Getopt-Kinoko

A command line parsing tool which written in Perl6 .

This module can help you parsing command line arguments. You can manager multi `OptionSet` just like defined multi sub `MAIN`, and `OptionSet` is a collection of multiple option which can used by `getopt` function interface. A option can be one of several `Option`, such as Integer、String etc .  Option can construct use string liter such as "c|count=i". This module provide both function and object-oriented interface, and you can use your custom parser when parsing.  

这个模块可以帮助你解析命令行的参数。本模块支持处理多组选项配置，就像定义多个`MAIN`那样。一个单独的选项配置含有多种选项，亦可单独使用函数接口解析。选项目前有整型、字符串、数组、哈希以及逻辑五种类型，选项的构造使用简单的字符串模式，比如`c|count=i`。本模块的接口目前有面向对象以及函数式接口，解析命令行的时候你还可以根据规则自定义自己的解析器。

## Usage

具体可以参考项目中的例子。

See sample.

## Installation

 + install with panda

	panda install Getopt::Kinoko

+ install with zef

	zef install Getopt::Kinoko

	If `zef install Getopt::Kinoko` not working, please run `zef update` first.

+ install
	git clone https://github.com/araraloren/Getopt-Kinoko.git

	cd Getopt-Kinoko && zef install .
