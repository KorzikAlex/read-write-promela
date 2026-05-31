/* * 
* \author Коршков А. А. (3343);
* \author Жучков О.Д. (3343)
* Вариант 9
*/ 
// Количество процессов читателей
#define READERS_COUNT 3
// Количество процессов писателей
#define WRITERS_COUNT 3

// Семафор для входа в критическую секцию
// 1 - свободно, 0 - занято
byte entry = 1;
// Семафор для читателей
byte readerSem = 0;
// Семафор для писателей
byte writerSem = 0;

// Количество приостановленных читателей
byte delayedReaders = 0;
// Количество приостановленных писателей
byte delayedWriters = 0;

// Количество активных читателей
byte readers = 0;
// Количество активных писателей
byte writers = 0;

// byte critical_info = 0;

// Сигнал для семафора
inline Signal(sem) {
	sem < 1 -> sem++;
}

// Ожидание для семафора
inline Wait(sem) {
	sem > 0 -> sem--;
}

// Подпрограмма, которая выполняется после каждой начальной и конечной операций.
inline SignalProcess() {
	if
	:: (writers > 0 || delayedReaders > 0) -> 
		delayedReaders--;
		Signal(readerSem);
	:: (readers == 0 && writers == 0 && delayedWriters > 0) -> 
		delayedWriters--;
		Signal(writerSem);
	:: else -> Signal(entry);
	fi
}

// Функция чтения
inline StartRead() {
	Wait(entry);
	if
	:: (writers > 0) -> 
		delayedReaders++;
		Signal(entry);
		Wait(readerSem);
	fi
	readers++;
	SignalProcess();
}

// Функция завершения чтения
inline EndRead() {
	Wait(entry);
	readers--;
	SignalProcess();
}

// Функция записи
inline StartWrite() {
	Wait(entry);
	if
	:: (writers > 0 || readers > 0) -> 
		delayedWriters++;
		Signal(entry);
		Wait(writerSem);
	fi
	writers++;
	SignalProcess();
}

// Функция завершения записи
inline EndWrite() {
	Wait(entry);
	writers--;
	SignalProcess();
}

// Для варианта
// Функция отпуска приостановленных читателей, если они есть
inline DropDelayedReaders() {
	do
	:: delayedReaders > 0 -> 
		delayedReaders--;
		Signal(readerSem);
	:: else -> break;
	od
}

// Процесс "Читатель"
proctype Reader() {
	printf("Hello,I'm a Reader\n");
	do
	:: true -> 
// Секция чтения
		StartRead();
// Чтение данных
		
		printf("Reader read data. Readers: %d,Writers: %d\n",readers,writers);
		
// Нельзя одновременно писать и читать
		assert(writers == 0);
		
		EndRead();
// Конец секции чтения
	od;
};

// Процесс "Писатель"
proctype Writer() {
	printf("Hello,I'm a Writer\n");
	do
	:: true -> 
// Секция записи
		StartWrite();
// Запись данных
		
// Писать может только один писатель
// Нельзя одновременно писать и читать
		assert(writers == 1 && readers == 0);
		
		printf("Writer wrote data. Readers: %d,Writers: %d\n",readers,writers);
		
		EndWrite();
// Конец секции записи
	od;
}

// Инициализирующий процесс
init {
// Запуск процессов читателей
	byte i = 0;
	do
	:: i < READERS_COUNT -> 
		run Reader();
		i++;
	:: else -> break;
	od;
	
// Запуск процессов писателей
	byte j = 0;
	do
	:: j < WRITERS_COUNT -> 
		run Writer();
		j++;
	:: else -> break;
	od;
}



// Проверка корректности

// Инварианты
// Инвариант для правильности алгоритма: если есть писатели, то их ровно один и нет читателей
#define INV1 ((writers > 0) -> (writers == 1) && (readers == 0))

// Разделённая бинарная семафора (в любой момент времени может быть занято не более одного из трёх семафоров)
#define INV2 ((0 <= entry + readerSem + writerSem) && (entry + readerSem + writerSem <= 1))

// Инвариант для ограничения количества писателей: не может быть более одного активного писателя
#define INV3 (writers <= 1)

// ltl свойства
// Свойство 1: всегда выполняется инвариант INV1
ltl p1 { [] INV1 }

// Свойство 2: всегда выполняется инвариант INV2
ltl p2 { [] INV2 }

// Свойство 3: Писать может только один писатель
ltl one_writer { [] INV3 }
