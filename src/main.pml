/* * 
* \author Коршков А. А. (3343);Жучков О.Д. (3343)
* Вариант 9
*/ 

// Семафор для входа в критическую секцию
byte entry = 1;
// Семафор для читателей
byte readerSem = 0;
// Семафор для писателей
byte writerSem = 0;

// Количество приостановленных читателей
int delayedReaders = 0;
// Количество приостановленных писателей
int delayedWriters = 0;

// Количество активных читателей
int readers = 0;
// Количество активных писателей
int writers = 0;

// Сигнал для семафора
#define signal(sem) (sem = 1)
// Ожидание для семафора
#define wait(sem) (sem = 0)

// Подпрограмма, которая выполняется после каждой начальной и конечной операций.
inline SignalProcess() {
	if
	:: (writers > 0 || delayedReaders > 0) -> 
		delayedReaders--;
		signal(readerSem);
	:: (readers == 0 && writers == 0 && delayedWriters > 0) -> 
		delayedWriters--;
		signal(writerSem);
	:: else -> signal(entry);
	fi
}

// Функция чтения
inline StartRead() {
	wait(entry);
	if
	:: (writers > 0) -> 
		delayedReaders++;
		signal(entry);
		wait(ReaderSem);
	fi
	SignalProcess();
}

// Функция завершения чтения
inline EndRead() {
	wait(entry);
	readers--;
	SignalProcess();
}

// Функция записи
inline StartWrite() {
	wait(entry);
	if
	:: (writers > 0 || readers > 0) -> 
		delayedWriters++;
		signal(entry);
		wait(WriterSem);
	fi
	writers++;
	SignalProcess();
}

// Функция завершения записи
inline EndWrite() {
	wait(entry);
	writers--;
	SignalProcess();
}

// Процесс "Читатель"
proctype Reader() {
	printf("Hello,I'm a Reader\n");
};

// Процесс "Писатель"
proctype Writer() {
	printf("Hello,I'm a Writer\n");
}

// Инициализирующий процесс
init {
// Инициализация семафоров
	run Reader();
	run Writer();
}

// Проверка корректности

// Инварианты

// Инвариант для правильности алгоритма: если есть писатели, то их ровно один и нет читателей
#define INV1 ((writers > 0) -> (writers == 1) && (readers == 0))

// Разделённая двоичная семафора
#define INV2 ((0 <= entry + readerSem + writerSem) && (entry + readerSem + writerSem <= 1))

// ltl свойства

// Свойство 1: всегда выполняется инвариант INV1
ltl p1 { [] INV1 }

// Свойство 2: всегда выполняется инвариант INV2
ltl p2 { [] INV2 }
