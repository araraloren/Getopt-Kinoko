# Getopt-Kinoko

A command line parsing tool which written in Perl6 .

这个模块可以帮助你解析命令行的参数。本模块支持处理多组选项配置，就像定义多个`MAIN`那样。选项目前有整型、字符串、数组、哈希以及逻辑五种类型，选项的构造使用简单的字符串模式，比如`c|count=i`。本模块的接口目前有面向对象以及函数式接口，解析命令行的时候你还可以根据规则自定义自己的解析器。

## Usage

具体可以参考项目中的例子。

## Installation

+ install with panda
	
	Not support

+ install with zef

	git clone https://github.com/araraloren/Getopt-Kinoko.git
	
	cd Getopt-Kinoko && zef install .
