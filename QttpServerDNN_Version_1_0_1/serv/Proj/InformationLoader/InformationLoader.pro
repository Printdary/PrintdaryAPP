QT -= gui
QT += network

CONFIG += c++11 console
CONFIG -= app_bundle


# The following define makes your compiler emit warnings if you use
# any feature of Qt which as been marked deprecated (the exact warnings
# depend on your compiler). Please consult the documentation of the
# deprecated API in order to know how to port your code away from it.
DEFINES += QT_DEPRECATED_WARNINGS

# You can also make your code fail to compile if you use deprecated APIs.
# In order to do so, uncomment the following line.
# You can also select to disable deprecated APIs only up to a certain version of Qt.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += main.cpp \
    InfoReceiver.cpp \
    Loader.cpp \
    Compare.cpp \
    InfoProvider.cpp   

HEADERS += \
    InfoReceiver.h \
    Loader.h \
    Compare.h \
    InfoProvider.h
   
LIBS += -L/usr/local/lib
INCLUDEPATH += /usr/local/includ
LIBS +=-lopencv_highgui 
LIBS+=-lopencv_imgproc
LIBS+=-lopencv_core 
LIBS+=-lopencv_imgcodecs 
LIBS+=-lopencv_features2d
LIBS+=-lopencv_calib3d
# unix:!macx: LIBS += -L$$PWD/../../../opencv3/opencv-3.2.0/build/lib/ -lopencv_calib3d

#INCLUDEPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include
#DEPENDPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include

# unix:!macx: LIBS += -L$$PWD/../../../opencv3/opencv-3.2.0/build/lib/ -lopencv_imgcodecs

# INCLUDEPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include
# DEPENDPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include

# unix:!macx: LIBS += -L$$PWD/../../../opencv3/opencv-3.2.0/build/lib/ -lopencv_highgui

# INCLUDEPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include
# DEPENDPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include



# unix:!macx: LIBS += -L$$PWD/../../../opencv3/opencv-3.2.0/build/lib/ -lopencv_core

# INCLUDEPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include
# DEPENDPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include

# unix:!macx: LIBS += -L$$PWD/../../../opencv3/opencv-3.2.0/build/lib/ -lopencv_features2d

# INCLUDEPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include
# DEPENDPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include

# unix:!macx: LIBS += -L$$PWD/../../../opencv3/opencv-3.2.0/build/lib/ -lopencv_imgproc

# INCLUDEPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include
# DEPENDPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include

# unix:!macx: LIBS += -L$$PWD/../../../opencv3/opencv-3.2.0/build/lib/ -lopencv_xfeatures2d

# INCLUDEPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include
# DEPENDPATH += $$PWD/../../../opencv3/opencv-3.2.0/build/include

