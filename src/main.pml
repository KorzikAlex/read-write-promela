/* * 
* \author Коршков А. А. (3343); Жучков О.Д. (3343)
* Вариант 9
*/ 
byte entry = 0; // Мьютекс для входа в критическую секцию
byte ReaderSem = 0; // Очередь для читателей
byte WriterSem = 0; // Очередь для писателей

int delayedReaders = 0;
int delayedWriters = 0;

int readers = 0;
int writers = 0;

// Читатель
proctype Reader() {
    printf("Hello, I'm a Reader\n");
};

// Писатель 
proctype Writer() {
    printf("Hello, I'm a Writer\n");
}

// Инициализирующий процесс
init {
    // Инициализация семафоров
    printf("Initializing semaphores...\n");

    run Reader();
    run Writer();
}

// ltl свойства

#define ltl1 ((writers > 0) -> (writers == 1) && (readers == 0))
#define ltl2 ((0 <= entry + ReaderSem + WriterSem) && (entry + ReaderSem + WriterSem <= 1))

// ltl { [] ltl1 }
// ltl { [] ltl2 }
