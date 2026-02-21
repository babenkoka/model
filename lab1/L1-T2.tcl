# Создать новый экземпляр объекта Simulator
set ns [new Simulator]

# Установить разные цвета для потоков (для nam)
$ns color 1 Blue
$ns color 2 Red

# Открыть трейс-файл для nam
set nf [open out.nam w]
$ns namtrace-all $nf

# Задать процедуру 'finish'
proc finish {} {
	global ns nf
	$ns flush-trace
	# Закрыть трейс-файл nam
	close $nf
	exit 0
}

# Создаем 4 узла
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Создать линки между узлами
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail

# Установить размер очереди на линке (n2-n3) в 10
$ns queue-limit $n0 $n2 10
$ns queue-limit $n1 $n2 10
$ns queue-limit $n2 $n3 10

# Задать расположение (для nam)
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link-op $n2 $n3 orient right

# Задать монитор очереди (n2-n3) (для nam)
$ns duplex-link-op $n2 $n3 queuePos 0.5

# Установим TCP-соединения
set tcp [new Agent/TCP]
$tcp set class_ 2
$ns attach-agent $n0 $tcp
set sink [new Agent/TCPSink]
$ns attach-agent $n3 $sink
$ns connect $tcp $sink
$tcp set fid_ 1 

# Установим соединение FTP поверх TCP
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ftp set type_ FTP

# Установим TCP-соединения
#set tcp [new Agent/TCP]
#$tcp set class_ 2
#$ns attach-agent $n1 $tcp
#set sink [new Agent/TCPSink]
#$ns attach-agent $n3 $sink
#$ns connect $tcp $sink
#$tcp set fid_ 2 

# Установим UDP-соединение
set udp [new Agent/UDP]
$ns attach-agent $n1 $udp
set null [new Agent/Null]
$ns attach-agent $n3 $null
$ns connect $udp $null
$udp set fid_ 2

# Установить соединение CBR поверх UDP
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
#$cbr attach-agent $tcp
$cbr set type_ CBR
$cbr set packet_size_ 1000
$cbr set rate_ 1mb
$cbr set random_ false

# Задать планировщик (в секундах)
$ns at 0.1 "$cbr start"
$ns at 1.0 "$ftp start"
$ns at 4.0 "$ftp stop"
$ns at 4.5 "$cbr stop"

# Отсоединить tcp и sink agent (не обязательно)
$ns at 4.5 "$ns detach-agent $n0 $tcp ; $ns detach-agent $n3 $sink"

# Вызвать процедуру 'finish' на 5 секунде
$ns at 5.0 "finish"

# Напечатать размер пакета CBR и интервал
puts "CBR packet size = [$cbr set packet_size_]"
puts "CBR interval = [$cbr set interval_]"

# Запуск
$ns run
