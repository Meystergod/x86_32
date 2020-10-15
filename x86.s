.data

error_size:
    .string "Введена некорректная размерность. Размерность должна быть больше 0.\n"

rotate270_array:
    .string "\nМассив, повёрнутый на 270 градусов:\n\n"

rotate90_array:
    .string "\nМассив, повёрнутый на 90 градусов:\n\n"

rotate180_array:
    .string "\nМассив, повёрнутый на 180 градусов:\n\n"

input_array:
    .string "\nВведённый массив:\n\n"

enter_size_array:
    .string "\nВведите размерность массива: "

enter_line_array:
    .string "\nВвод строки №%d.\n"

enter_element_array:
    .string "Введите %d элемент строки: "

scan_format_array:
    .string "%d   "

scan_format_size_array:
    .string "%d"

next_line:
    .string "\n"

number_line:
    .space 4

total_array_size:
    .space 4

total_line_size:
    .space 4

start_array_point:
    .space 4

.equ elem_size, 4

.text
.globl main

main:
    /* Вывод сообщения */
    // Формат вывода
    pushl $enter_size_array
    // Вызов printf
    call printf
    // Выравнивание стека
    addl $4, %esp

    /* Ввод размерности */
    // Адрес данных для ввода
    pushl $number_line
    // Формат ввода
    pushl $scan_format_size_array
    // Вызов scanf
    call scanf
    // Выравнивание стека
    addl $8, %esp

    // Проверка введённой размерности (если <= нулю, то завершается программа с сообщением об ошибке)
    cmpl $0, number_line
    je error_number_line
    jng error_number_line

    /* Вызов функции инициализации массива */
    call init_array
    
    /* Вывод сообщения */
    // Формат вывода
    pushl $input_array
    // Вызов printf
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Вызов функции для вывода исходного массива
    call print_array

    /* Вывод сообщения */
    // Формат вывода
    pushl $rotate90_array
    // Вызов printf
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Вызов функции для вывода массива, который повёрнут на 90 градусов
    call start_rotate_matrix_90

    /* Вывод сообщения */
    // Формат вывода
    pushl $rotate180_array
    // Вызов printf
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Вызов функции для вывода массива, который повёрнут на 180 градусов
    call start_rotate_matrix_180

    /* Вывод сообщения */
    // Формат вывода
    pushl $rotate270_array
    // Вызов printf
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Вызов функции для вывода массива, который повёрнут на 270 градусов
    call start_rotate_matrix_270

    /* Вывод сообщения ("\n") */
    // Формат вывода
    pushl $next_line
    // Вызов printf
    call printf
    // Выравнивание стека
    addl $4, %esp

    /* Очистка памяти */
    // Переход в начало массива
    movl start_array_point, %esi
    pushl %esi
    // Вызов free
    call free
    // Выравнивание стека
    addl $4, %esp

    // Обнуление eax
    xor %eax, %eax

    // Выход из функции main (завершение программы)
    ret

/* Функция инициализации и заполнения массива */
init_array:
    // Вычисление необходимого объёма памяти
    // Умножаем размер одного символа на количество символов в строке и столбце
    movl $elem_size, %eax
    mull number_line
    movl %eax, total_line_size
    mull number_line
    movl %eax, total_array_size

    // Вызов malloc и выделение памяти
    pushl $total_array_size
    call malloc
    // Выравнивание стека
    addl $4, %esp
    // Сохраняем указатель на начало массива
    movl %eax, %esi
    movl %eax, start_array_point
    
    // edi - счётчик введённых строк
    xor %edi, %edi

/* Функция реализации строк */
enter_line:
    // ebx - счётчик введённых элементов строки
    xor %ebx, %ebx

    // Проверка на введённый строки (если счётчик = количеству строк, то завершаем заполнение массива)
    cmpl number_line, %edi
    je end_init_array

    // Увеличение счётчика на 1, чтобы индексация начиналась не с 0
    incl %edi
    pushl %edi
    pushl $enter_line_array
    call printf
    // Уменьшение счётчика на 1 (возвращаем в исходное состояние)
    decl %edi
    // Выравнивание стека
    addl $8, %esp

/* Функция ввода элементов строки */
enter_element:
    // Увеличение счётчика на 1, чтобы индексация начиналась не с 0
    incl %ebx
    pushl %ebx
    pushl $enter_element_array
    call printf
    // Уменьшение счётчика на 1 (возвращаем в исходное состояние)
    decl %ebx
    // Выравнивание стека
    addl $8, %esp

    // Ввод элемента
    pushl %esi
    pushl $scan_format_size_array
    call scanf
    // Выравнивание стека
    addl $8, %esp
    addl $elem_size, %esi

    // Увеличение счётчика элементов строки на 1, после ввода элемента строки
    incl %ebx
    // Проверка количества введённых элементов с размерностью строки. Если не равно, то продолжаем ввод
    cmpl %ebx, number_line
    jne enter_element
    // Увеличение счётчика строк на 1, после ввода всех элементов строки
    incl %edi
    // Переход в функции ввода следующей строки
    jmp enter_line

/* Функция завершения инициализации и заполнения массива */
end_init_array:
    ret

/* Функция вывода исходного массива */
print_array:
    // Обнуление регистров, которые будут необходимы
    // Регистр ebx - счётчик символов в строке
    // Регистр edi - счётчик строк
    // Регистр esi - хранение указателя на начало массива
    movl $0, %ebx
    movl $0, %edi
    movl $0, %esi
    // Внесение указателя на начало массива в регстр esi
    movl start_array_point, %esi

/* Функция вывода строки */
print_line:
    // Проверка на выведенное количество строк
    cmpl %edi, number_line
    je print_array_end

    // Проверка на выведенное количество элементов строки
    cmpl %ebx, number_line
    je print_line_end

    pushl (%esi)
    pushl $scan_format_array
    addl $4, %esi
    call printf
    // Выравнивание стека
    addl $8, %esp

    // Увеличение счётчика элементов строки на 1, после вывода элемента строки
    incl %ebx
    // Повторяем вывод, пока не будут выведенны все элементы строки
    jmp print_line

/* Функция перехода на новую строку */
print_line_end:
    pushl $next_line
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Увеличение счётчика строк на 1
    incl %edi
    // Обнуление счётчика элементов строки
    movl $0, %ebx
    // Переход к выводу следующей строки
    jmp print_line

/* Функция окончания вывода исходного массива */
print_array_end:
    // Завершение функции
    ret    

/* Функция вывода массива, который повёрнут на 90 градусов по часовой стрелке */
start_rotate_matrix_90:
    // Обнуление регистров, которые будут необходимы
    // Регистр ebx - счётчик символов в строке
    // Регистр edi - счётчик строк
    // Регистр esi - хранение указателя на начало массива
    movl $0, %edi
    movl $0, %ebx
    movl $0, %esi
    // Внесение указателя на начало массива в регстр esi
    movl start_array_point, %esi
    // Смещение указателя на количество всех элементов массива вперед
    addl (total_array_size), %esi

/* Функция вывода строк массива, который повёрнут на 90 градусов по часовой стрелке */
rotate_matrix_90:
    // Проверка на выведенное количество строк
    cmpl %edi, number_line
    je end_print_matrix_90

    // Проверка на выведенное количество элементов строки
    cmpl %ebx, number_line
    je next_line_rotate_90

    // Смещение указателя на количество элементов одной строки назад
    subl (total_line_size), %esi
    
    pushl (%esi)
    pushl $scan_format_array
    call printf
    // Выравнивание стека
    addl $8, %esp

    // Увеличение счётчика элементов строки на 1, после вывода элемента строки
    incl %ebx
    // Повторяем вывод, пока не будут выведенны все элементы строки
    jmp rotate_matrix_90

/* Функция перехода на новую строку */
next_line_rotate_90:
    pushl $next_line
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Смещение указателя обратно на начало массива, затем на 1 вперед (необходимо для реализации)
    addl (total_array_size), %esi
    addl $4, %esi
    // Увеличение счётчика строк на 1
    incl %edi
    // Обнуление счётчика элементов строки
    movl $0, %ebx
    // Переход к выводу следующей строки
    jmp rotate_matrix_90

/* Функция окончания вывода массива, который повёрнут на 90 градусов по часовой стрелке */
end_print_matrix_90:
    // Завершение функции
    ret

/* Функция вывода массива, который повёрнут на 180 градусов по часовой стрелке */
start_rotate_matrix_180:
    // Обнуление регистров, которые будут необходимы
    // Регистр ebx - счётчик символов в строке
    // Регистр edi - счётчик строк
    // Регистр esi - хранение указателя на начало массива
    movl $0, %edi
    movl $0, %ebx
    movl $0, %esi
    // Внесение указателя на начало массива в регстр esi
    movl start_array_point, %esi
    // Смещение указателя на количество всех элементов массива вперед
    addl (total_array_size), %esi 

/* Функция вывода строк массива, который повёрнут на 180 градусов по часовой стрелке */
rotate_matrix_180:
    // Проверка на выведенное количество элементов строки
    cmpl %ebx, number_line
    je next_line_rotate_180

    // Проверка на выведенное количество строк
    cmpl %edi, number_line
    je end_print_matrix_180
    
    // Смещение указателя на 1 элемент назад
    subl $4, %esi
    pushl (%esi)
    pushl $scan_format_array
    call printf
    // Выравнивание стека
    addl $8, %esp
    
    // Увеличение счётчика элементов строки на 1, после вывода элемента строки
    incl %ebx
    // Повторяем вывод, пока не будут выведенны все элементы строки
    jmp rotate_matrix_180

/* Функция перехода на новую строку */
next_line_rotate_180:
    pushl $next_line
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Увеличение счётчика строк на 1
    incl %edi
    // Обнуление счётчика элементов строки
    movl $0, %ebx
    // Переход к выводу следующей строки
    jmp rotate_matrix_180

/* Функция окончания вывода массива, который повёрнут на 180 градусов по часовой стрелке */
end_print_matrix_180:
    // Завершение функции
    ret

/* Функция вывода массива, который повёрнут на 270 градусов по часовой стрелке */
start_rotate_matrix_270:
    // Обнуление регистров, которые будут необходимы
    // Регистр ebx - счётчик символов в строке
    // Регистр edi - счётчик строк
    // Регистр esi - хранение указателя на начало массива
    movl $0, %edi
    movl $0, %ebx
    movl $0, %esi
    // Внесение указателя на начало массива в регстр esi
    movl start_array_point, %esi
    // Смещение указателя на 1 элемент назад
    subl $4, %esi

/* Функция вывода строк массива, который повёрнут на 270 градусов по часовой стрелке */
rotate_matrix_270:
    // Проверка на выведенное количество строк
    cmpl %edi, number_line
    je end_print_matrix_270
    
    // Проверка на выведенное количество элементов строки
    cmpl %ebx, number_line
    je next_line_rotate_270

    // Смещение указателя на количество элементов одной строки вперед
    addl (total_line_size), %esi
    pushl (%esi)
    pushl $scan_format_array
    call printf
    // Выравнивание стека
    addl $8, %esp    
    // Увеличение счётчика элементов строки на 1, после вывода элемента строки
    incl %ebx
    // Повторяем вывод, пока не будут выведенны все элементы строки
    jmp rotate_matrix_270

/* Функция перехода на новую строку */
next_line_rotate_270:
    pushl $next_line
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Смещение указателя на количество всех элементов назад
    subl (total_array_size), %esi
    // Смещение указателя еще на 1 элемент назад
    subl $4, %esi
    // Увеличение счётчика строк на 1
    incl %edi
    // Обнуление счётчика элементов строки
    movl $0, %ebx
    // Переход к выводу следующей строки
    jmp rotate_matrix_270

/* Функция окончания вывода массива, который повёрнут на 270 градусов по часовой стрелке */
end_print_matrix_270:
    // Завершение функции
    ret

/* Функция для проверки введённой размерности */
error_number_line:
    // Формат вывода
    pushl $error_size
    // Вызов printf
    call printf
    // Выравнивание стека
    addl $4, %esp
    // Завершение функции
    ret
