# создание объекта Simulator
set ns [new Simulator]

$ns rtproto DV

set nf [open out.nam w]

$ns namtrace-all $nf

# открытие на запись файла трассировки out.tr
# для регистрации всех событий
set f [open out.tr w]

# все регистрируемые события будут записаны в переменную f
$ns trace-all $f

set N 6 
for {set i 0} {$i < $N} {incr i} {
	set n($i) [$ns node]
}

for {set i 0} {$i < [expr $N - 1]} {incr i} {
	$ns duplex-link $n($i) $n([expr ($i+1)%[expr $N - 1]]) 1Mb 10ms DropTail
}

$ns duplex-link $n(5) $n(1) 1Mb 10ms DropTail

set tcp0 [new Agent/TCP/Newreno]
$ns attach-agent $n(0) $tcp0

set sink [new Agent/TCPSink/DelAck]
$ns attach-agent $n(5) $sink

$ns connect $tcp0 $sink

set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ftp0 set type_ FTP







# процедура finish закрывает файлы трассировки
# и запускает визуализатор nam
proc finish {} {
	# описание глобальных переменных
	global ns f nf 
	# прекращение трассировки
	$ns flush-trace 
	# закрытие файлов трассировки
	close $f 
	# закрытие файлов трассировки nam
	close $nf 
	# запуск nam в фоновом режиме
	exec nam out.nam &
	exit 0
}

$ns at 0.5 "$ftp0 start"
$ns rtmodel-at 1.0 down $n(0) $n(1)
$ns rtmodel-at 2.0 up $n(0) $n(1)
$ns at 4.5 "$ftp0 stop"
$ns at 5.0 "finish"
# запуск модели
$ns run
