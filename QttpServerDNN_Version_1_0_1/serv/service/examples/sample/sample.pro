TEMPLATE = app
QT += testlib
QT += core
QT -= gui
DESTDIR = $$PWD
SOURCES += $$PWD/main.cpp
TARGET = sample

INCLUDEPATH += /usr/local/include
#INCLUDEPATH += /home/ubuntu/miniconda3/include

#LIBS += -L/home/ubuntu/miniconda3/lib/
#LIBS += -lopencv_core
#LIBS += -lopencv_highgui
#LIBS += -lopencv_imgproc
#LIBS += -lopencv_videoio
#LIBS += -lopencv_imgcodecs
#LIBS += -lopencv_video
#LIBS += -lboost_system

macx {
    # Since things are buried in the app folder, we will copy configs there.
    MediaFiles.files = \
        $$PWD/config/global.json \
        $$PWD/config/routes.json

    MediaFiles.path = Contents/MacOS/config
    QMAKE_BUNDLE_DATA += MediaFiles
}

message('Including config files')
include($$PWD/config/config.pri)


message(LIBS $$LIBS)
message('Including core files')
include($$PWD/../../core.pri)

message(LIBS $$LIBS)
