/* * 
* \author Коршков А. А. (3343);
* \author Жучков О.Д. (3343)
* Вариант 9
*/ 
// Количество процессов читателей
#define READERS_COUNT 3
// Количество процессов писателей
#define WRITERS_COUNT 3

// Семафоры
byte entry = 1;
byte readerSem = 0;
byte writerSem = 0;

byte delayedReaders = 0;
byte delayedWriters = 0;

byte readers = 0;
byte writers = 0;

byte shared_memory = 0;

// busy-wait
inline Signal(sem) {
	sem++
}

inline Wait(sem) {
	atomic { sem > 0 -> sem-- }
}

inline SignalProcess() {
	if
	:: (writers == 0 && delayedReaders > 0) ->  //в учебнике (writers == 0 || delayedReaders > 0), предполагаемо опечатка
		delayedReaders--;
		Signal(readerSem);
	:: (readers == 0 && writers == 0 && delayedWriters > 0 && delayedReaders == 0) -> //delayedReaders == 0 добавлен для включения инверсии первого условия (чтобы не делать вложенные if)
		delayedWriters--;
		Signal(writerSem);
	:: else -> Signal(entry);
	fi
}

inline StartRead() {
	Wait(entry);
	if
	:: (writers > 0) -> 
		delayedReaders++;
		Signal(entry);
		Wait(readerSem);
	:: else -> 
	fi
	readers++;
	SignalProcess();
}

inline EndRead() {
	Wait(entry);
	readers--;
	SignalProcess();
}

inline StartWrite() {
	Wait(entry);
	if
	:: (writers > 0 || readers > 0) -> 
		delayedWriters++;
		Signal(entry);
		Wait(writerSem);
	:: else -> 
	fi
	writers++;
	SignalProcess();
}

inline EndWrite() {
	Wait(entry);
	writers--;
	SignalProcess();
}

proctype Reader(byte rid) {
	do
	:: true -> 
		StartRead();
		printf("%d: read %d (Readers: %d, Writers: %d)\n",rid,shared_memory,readers,writers);
		EndRead();
	od;
};

proctype Writer(byte wid) {
	do
	:: true -> 
		StartWrite();
		shared_memory = wid
		printf("%d: write %d (Readers: %d, Writers: %d)\n",wid,shared_memory,readers,writers);
		EndWrite();
	od;
}

init {
// Запуск процессов читателей
	byte i = 0;
	do
	:: i < READERS_COUNT -> 
		run Reader(i);
		i++;
	:: else -> break;
	od;
// Запуск процессов писателей
	byte j = 0;
	do
	:: j < WRITERS_COUNT -> 
		run Writer(j);
		j++;
	:: else -> break;
	od;
}


// Инвариант для правильности алгоритма (стр. 143 Бен-Ари): если есть писатели, то он ровно один и нет читателей
#define safe_readers_writers ((writers > 0) -> (writers == 1) && (readers == 0))
ltl correct { [] safe_readers_writers }

// Инвариант разделенного бинарного семафора (стр. 143 Бен-Ари): сумма S.L не превышает единицы
#define split_binary_semaphor ((0 <= entry + readerSem + writerSem) && (entry + readerSem + writerSem <= 1))
ltl semaphor { [] split_binary_semaphor }

// Если производится запись и есть приостановленные читатели, в будущем все эти читатели получат доступ
ltl reader_priority { [] ((writers > 0 && delayedReaders > 0) -> <> (readers > 0 && delayedReaders == 0)) }
