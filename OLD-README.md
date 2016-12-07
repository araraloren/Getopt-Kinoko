# Getopt-Kinoko

A command line parsing tool which written in Perl6 .

Getopt::Kinoko is a powerful command line parsing module, support function style interface getopt> can handle a single OptionSet and OO style interface which can handle multi OptionSet at same time(just as overload the MAIN routine). OptionSet is a class used to describe a set of Option, It support group the Options together with Group::Normal Group::Radio Group::Multi Group, and you can also set a NonOption::Front NonOption::All NonOption handle user input non-option parameters. The option of OptionSet can be one kind of Option::String Option::Integer Option::Boolean etc. They use a simple string such as "h|help=b;" describe basic configuration, and you can through OptionSet's interface set their default value and callback funtion.

Getopt::Kinoko是一个强大的命令行解析模块，支持使用函数式接口处理单个OptionSet以及面向对象接口处理多个OptionSet(就如同重载的MAIN函数)，OptionSet是用来描述一组选项的类，OptionSet支持以normal(普通选项)、radio(单一选项)、multi(多选选项)等方式把选项组合在一起，并且还可以设置OptionSet的front(第一个非选项参数处理设施)、all(所有非选项参数处理设施)处理用户输入的非选项参数。Getopt::Kinoko，OptionSet中的选项可以是string(字符串)、integer(整数)、boolean(布尔)等选项中的一种，选项使用字符串来描述基本配置，你可以通过OptionSet的接口设置它们的默认值以及当选项被用户设置时的回调函数。

## Usage

### Find file example

```Perl6
#!/usr/bin/env perl6

use Getopt::Kinoko;

my OptionSet $opts .= new();

$opts.insert-normal("h|help=b;v|version=b;");
$opts.insert-multi("w=b;");
$opts.insert-radio("d|directory=b;f|file=b;l|link=b;", :force);
$opts.push-option(
  "size-limit=i",
  callback => -> \value {
    die "Invalid integer value."
      if value !~~ Int;
  },
  comment => "the min size limit of file"
);
$opts.set-comment('help',       "print this help message");
$opts.set-comment('version',    "print the version");
$opts.set-comment('w',          "match whole file name");
$opts.set-comment('d',          "specify search file type to directory");
$opts.set-comment('f',          "specify search file type to normal file");
$opts.set-comment('l',          "specify search file type to link");
&main(getopt($opts, :gnu-style));

sub main(@noa) {
  note "Version 0.0.1"
    if $opts{'v'};

  if $opts{'h'} || $opts{'v'} {
    note "{$*PROGRAM-NAME} " ~ $opts.usage ~ "\n";
    note(.join("") ~ "\n") for $opts.comment(4);
    exit 0;
  }

  die "Not support multi keyword"
    if +@noa > 2;

  die "Need more arguments"
    if +@noa < 2;

  my ($dir, $key) = @noa;

  die "Invalid directory {$dir}"
    if $dir.IO !~~ :d;

  &search($opts, $dir, $key, -> $file { say $file.path(); });
}

sub search(OptionSet $opts, Str $dir, Str $key, &callback) {
  for $dir.IO.dir(:all) -> $file {
    my $name = $file.basename;

    next if $opts{'w'} && $name ne $key;
    next if $opts{'d'} && !$file.d;
    next if $opts{'f'} && (!$file.f || $file.s < $opts{'size-limit'}.Int);
    next if $opts{'l'} && !$file.l;

    &callback($file);
  }
}
```

更多样例请参考sample。

## Installation

+ install with panda

	`panda install Getopt::Kinoko`

+ install with zef

	`zef install Getopt::Kinoko`

	If `zef install Getopt::Kinoko` not working, please run `zef update` first.

+ install

	`git clone https://github.com/araraloren/Getopt-Kinoko.git`

	`cd Getopt-Kinoko && zef install` .
