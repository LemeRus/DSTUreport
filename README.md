Система сборки LaTeX документов по российским ГОСТам
===========

Данный фреймворк является форком от НавСибЛабовского, может всё то же самое и добавляет свой функционал, настоятельно рекомендую почитать ридми из оригинального репозитория, где описаны особенности проекта.

Основные изменения относительно `Korogodin/NSLReport`:
- добавлены команды для быстрой вёрстки титульников отчётов и курсовых по стандартам ДГТУ
- значительно расширена преамбула, добавлено много полей для вёрстки титульников
- незначительно доработаны рамки

# Где примеры?
С примерами в формате pdf можно ознакомиться в директории examples. Там же лежат исходники, которые используются командой make по-умолчанию.

# Как составить свой документ?
Самый простой вариант - начните править файлы в директории tex любым редактором кода. Пересборку документа можно осуществлять из директории tex командами make или pdflatex rpz.tex.

Можно редактировать текст документа в TexMaker. В этом случае откройте rpz.tex и назначьте его мастер-документом (Options->Define Curre...). Теперь вы можете пересобирать документ простым нажатием F1.

В директорию graphics кладите изображения и схемы. Растровые - в img, векторные - в svg. При сборке они будут преобразованы в pdf и помещены в inc. Не кладите изображения в inc, это временная директория. Она будет удалена по команде make clean!

Когда вы добавили новое изображение и подключили его в документе с помощью includegraphics, то пересоберите документ командой make. Это сконвертирует ваше изображение и перенесет результат в inc. После этого опять можно пересобирать документ по-быстрому в TexMaker.

Вы можете разбивать документ на несколько .tex файлов. Называйте их по шаблону dd-name.tex, где dd - пара арабских цифр. Чем раньше этот файл используется в документе, тем меньше должна быть цифра. Так при упорядочивании файлов по имени они сохранят порядок изложения. А ещё, так система сборки поймет, что для этих файлов нужно подготовить изображения.
В примерах файлы разбиты именно так и подключены в мастер-документ rpz.tex.

Титульники верстаются постранично, то есть один лист -- одна команда из sty/DSTUTitles. В комментариях описаны команды и их аргументы.
Описание источников литературы добавляется в файл rpz.bib в формате BibTeX. Фреймворк использует biblatex и biber, кодировку utf8.
