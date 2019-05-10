# data.table包的用法

R语言data.table包是自带包data.frame的升级版，用于数据框格式数据的处理，最大的特点快。包括两个方面，一方面是写的快，代码简洁，只要一行命令就可以完成诸多任务，另一方面是处理快，内部处理的步骤进行了程序上的优化，使用多线程，甚至很多函数是使用C写的，大大加快数据运行速度。因此，在对大数据处理上，使用data.table无疑具有极高的效率。这里我们主要讲的是它对数据框结构的快捷处理。

## fread

````R
fread(input, sep="auto", sep2="auto", nrows=-1L, header="auto", na.strings="NA", file,
stringsAsFactors=FALSE,verbose=getOption("datatable.verbose"), autostart=1L,skip=0L, select=NULL, drop=NULL, colClasses=NULL,integer64=getOption("datatable.integer64"),
# default: "integer64"
dec=if (sep!=".") "." else ",", col.names,
check.names=FALSE, encoding="unknown", quote="\"",
strip.white=TRUE, fill=FALSE, blank.lines.skip=FALSE, key=NULL,
showProgress=getOption("datatable.showProgress"),
      # default: TRUE
data.table=getOption("datatable.fread.datatable") 
      # default: TRUE
)
````

input输入的文件，或者字符串（至少有一个"\n")；
sep列之间的分隔符；
sep2，分隔符内再分隔的分隔符，功能还没有应用；
nrow，读取的行数，默认-l全部，nrow=0仅仅返回列名；
header第一行是否是列名；
na.strings,对NA的解释；
file文件路径，再确保没有执行shell命令时很有用，也可以在input参数输入;
stringsASFactors是否转化字符串为因子，
verbose，是否交互和报告运行时间；
autostart，机器可读这个区域任何行号，默认1L,如果这行是空，就读下一行;
skip跳过读取的行数，为1则从第二行开始读，设置了这个选项，就会自动忽略autostart选项，也可以是一个字符,skip="string",那么会从包含该字符的行开始读；
select,需要保留的列名或者列号，不要其它的；
drop,需要取掉的列名或者列号，要其它的；
colClasses，类字符矢量，用于罕见的覆盖而不是常规使用，只会使一列变为更高的类型，不能降低类型；
integer64,读如64位的整型数;
dec,小数分隔符，默认"."不然就是","
col.names,给列名，默认试用header或者探测到的，不然就是V+列号;
encoding，默认"unknown"，其它可能"UTF-8"或者"Latin-1"，不是用来重新编码的，而是允许处理的字符串在本机编码;
quote,默认"""，如果以双引开头，fread强有力的处理里面的引号，如果失败了就会用其它尝试，如果设置quote="",默认引号不可用
strip.white，默认TRUE，删除结尾空白符，如果FALSE,只取掉header的结尾空白符；
fill,默认FALSE，如果TRUE，不等长的区域可以自动填上，利于文件顺利读入；
blank.lines.skip,默认FALSE,如果TRUE，跳过空白行
key，设置key，用一个或多个列名，会传递给setkey
showProgress,TRUE会显示脚本进程，R层次的C代码
data.table,TRUE返回data.table，FALSE返回data.frame

## fwrite

````R
fwrite(x, file = "", append = FALSE, quote = "auto",
sep = ",", sep2 = c("","|",""),
eol = if (.Platform$OS.type=="windows") "\r\n" else "\n",
na = "", dec = ".", row.names = FALSE, col.names = TRUE,
qmethod = c("double","escape"),
logicalAsInt = FALSE, dateTimeAs = c("ISO","squash","epoch","write.csv"),
buffMB = 8L, nThread = getDTthreads(),
showProgress = getOption("datatable.showProgress"),
verbose = getOption("datatable.verbose"))
````

x,具有相同长度的列表，比如data.frame和data.table等；
file，输出文件名,""意味着直接输出到操作台；
append，如果TRUE,在原文件的后面添加；
quote，如果"auto",因子和列名只有在他们需要的时候才会被加上双引号，例如该部分包括分隔符，或者以"\n"结尾的一行，或者双引号它自己，如果FALSE，那么区域不会加上双引号，如果TRUE，就像写入CSV文件一样，除了数字，其它都加上双引号；
sep,列之间的分隔符；
sep2,对于是list的一列，写出去时list成员间以sep2分隔，它们是处于一列之内，然后内部再用字符分开；
eol，行分隔符，默认Windows是"\r\n",其它的是"\n"；
na,na值的表示，默认""；
dec，小数点的表示，默认"."；
row.names，是否写出行名，因为data.table没有行名，所以默认FALSE；
col.names ，是否写出列名，默认TRUE，如果没有定义，并且append=TRUE和文件存在，那么就会默认使用FALSE;
qmethod,怎样处理双引号，"escape",类似于C风格，用反斜杠逃避双引，“double",默认，双引号成对；
logicalAsInt,逻辑值作为数字写出还是作为FALSE和TRUE写出；
dateTimeAS, 决定 Date/IDate,ITime和POSIXct的写出，"ISO"默认，-2016-09-12, 18:12:16和2016-09-12T18:12:16.999999Z;"squash",-20160912,181216和20160912181216999;"epoch",-17056，65536和1473703936;"write.csv"，就像write.csv一样写入时间，仅仅对POSIXct有影响，as.character将digits.secs转化字符并通过R内部UTC转回本地时间。前面三个选项都是用新的特定C代码写的，较快
buffMB,每个核心给的缓冲大小，在1到1024之间，默认80MB
nThread,用的核心数。
showProgress，在工作台显示进程，当用file==""时，自动忽略此参数
verbose，是否交互和报告时间

## data.table数据框结构处理语法

````R
data.table[ i , j , by]
````

 i 决定显示的行,可以是整型，可以是字符，可以是表达式，j 是对数据框进行求值，决定显示的列，by对数据进行指定分组，除了by ，也可以添加其它的一系列参数：keyby，with, nomatch, mult, rollollends, which, .SDcols, on。

###  i 决定显示的行

````R
DT = data.table(x=rep(c("b","a","c"),each=3), y=c(1,3,6), v=1:9)   #新建data.table对象DT
DT[2]   #取第二行
DT[2:3]   #取第二到第三行
DT[order(x)]  #将DT按照X列排序，简化操作,另外排序也可以setkey(DT,x)，出来的DT就已经是按照x列排序的了。用haskey(DT)判断DT是否已经设置了key，可以设置多个列作为key
DT[y>2]   #  DT$y>2的行
DT[!2:4]   #除了2到4行剩余的行
DT["a",on="x"]   #on 参数，DT[D,on=c("x","y")]取DT上"x","y"列上与D上“x"、"y"的列相关联的行，与D进行merge。比如此例取出DT 中 X 列为"a"的行，和"a"进行merge。on参数的第一列必须是DT的第一列
DT[.("a"), on="x"]  #和上面一样.()有类似与c()的作用
DT["a", on=.(x)]   #和上面一样
DT[x=="a"]   # 和上面一样,和使用on一样，都是使用二分查找法，所以它们速度比用data.frame的快。也可以用setkey之后的DT,输入DT["a"]或者DT["a",on=.(x)]如果有几个key的话推荐用on
DT[x!="b" | y!=3]  #x列不等于"b"或者y列不等于3的行
DT[.("b", 3), on=.(x, v)]  #取DT的x,v列上x="b",v=3的行
````

### j 对数据框进行求值输出

j 参数对数据进行运算，比如sum,max,min,tail等基本函数，输出基本函数的计算结果，还可以用n输出第n列，.N（总列数，直接在j输入.N取最后一列）,:=（直接在data.table上添加列，没有copy过程，所以快，有需要的话注意备份），.SD输出子集，.SD[n]输出子集的第n列，DT[,.(a = .(), b = .())] 输出一个a、b列的数据框，.()就是要输入的a、b列的内容,还可以将一系列处理放入大括号,如{tmp <- mean(y);.(a = a-tmp, b = b-tmp)}

````R
DT[,y]   #返回y列，矢量
DT[,.(y)]   #返回y列，返回data.table
DT[, sum(y)]   #对y列求和
DT[, .(sv=sum(v))]  #对y列求和，输出sv列，列中的内容就是sum(v)
DT[, .(sum(y)), by=x]   # 对x列进行分组后对各分组y列求总和
DT[, sum(y), keyby=x]   #对x列进行分组后对各分组y列求和，并且结果按照x排序
DT[, sum(y), by=x][order(x)]   #和上面一样，采取data.table的链接符合表达式
DT[v>1, sum(y), by=v]   #对v列进行分组后,取各组中v>1的行出来，各组分别对定义的行中的y求和
DT[, .N, by=x]  #用by对DT 用x分组后，取每个分组的总行数
DT[, .SD, .SDcols=x:y]  #用.SDcols 定义SubDadaColums（子列数据)，这里取出x到之间的列作为子集，然后.SD 输出所有子集
DT[2:5, cat(y, "\n")]  #直接在j 用cat函数，输出2到5列的y值
DT[, plot(a,b), by=x]   #直接在j用plot函数画图，对于每个x的分组画一张图
DT[, m:=mean(v), by=x] #对DT按x列分组，直接在DT上再添加一列m,m的内容是mean(v)，直接修改并且不输出到屏幕上
DT[, m:=mean(v), by=x] [] #加[]将结果输出到屏幕上
DT[,c("m","n"):=list(mean(v),min(v)), by=x][] # 按x分组后同时添加m,n 两列，内容是分别是mean(v)和min(v)，并且输出到屏幕
DT[, `:=`(m=mean(v),n=min(v)),by=x][]   #内容和上面一样，另外的写法
DT[,.(seq = min(y):max(v)), by=x]  #输出seq列，内容是min(a)到max(b)
DT[, c(.(y=max(y)), lapply(.SD, min)), by=x, .SDcols=y:v]  #对DT取y:v之间的列，按x分组，输出max(y),对y到v之间的列每列求最小值输出。
````

