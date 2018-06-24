QT -= gui

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

SOURCES += \
    AkazeFeatureMatcher.cpp \
    FeatureDetector.cpp \
    ORBFeatureMatcher.cpp \
    SiftFeatureMatcher.cpp \
    SurfFeatureMatcher.cpp \
    mainFeature.cpp \
    Controller.cpp


unix:!macx: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_calib3d

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH += $$PWD/../../../opencv/build/build/include

unix:!macx: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_imgcodecs

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH += $$PWD/../../../opencv/build/build/include

unix:!macx: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_highgui

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH += $$PWD/../../../opencv/build/build/include



unix:!macx: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_core

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH +=$$PWD/../../../opencv/build/build/include

unix:!macx: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_features2d

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH += $$PWD/../../../opencv/build/build/include

unix:!macx: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_imgproc

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH += $$PWD/../../../opencv/build/build/include

unix:!macx: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_xfeatures2d

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH += $$PWD/../../../opencv/build/build/include

HEADERS += \
    AkazeFeatureMatcher.h \
    FeatureDetector.h \
    FeatureMatcher.h \
    ORBFeatureMatcher.h \
    SiftFeatureMatcher.h \
    SurfFeatureMatcher.h \
    Parameters.h \
    Controller.h

win32:CONFIG(release, debug|release): LIBS += -L$$PWD/../../../opencv/build/build/lib/release/ -lopencv_core
else:win32:CONFIG(debug, debug|release): LIBS += -L$$PWD/../../../opencv/build/build/lib/debug/ -lopencv_core
else:unix: LIBS += -L$$PWD/../../../opencv/build/build/lib/ -lopencv_core

INCLUDEPATH += $$PWD/../../../opencv/build/build/include
DEPENDPATH += $$PWD/../../../opencv/build/build/include
