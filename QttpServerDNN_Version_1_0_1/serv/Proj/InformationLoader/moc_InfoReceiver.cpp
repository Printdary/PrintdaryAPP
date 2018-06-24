/****************************************************************************
** Meta object code from reading C++ file 'InfoReceiver.h'
**
** Created by: The Qt Meta Object Compiler version 67 (Qt 5.10.0)
**
** WARNING! All changes made in this file will be lost!
*****************************************************************************/

#include "InfoReceiver.h"
#include <QtCore/qbytearray.h>
#include <QtCore/qmetatype.h>
#if !defined(Q_MOC_OUTPUT_REVISION)
#error "The header file 'InfoReceiver.h' doesn't include <QObject>."
#elif Q_MOC_OUTPUT_REVISION != 67
#error "This file was generated using the moc from 5.10.0. It"
#error "cannot be used with the include files from this version of Qt."
#error "(The moc has changed too much.)"
#endif

QT_BEGIN_MOC_NAMESPACE
QT_WARNING_PUSH
QT_WARNING_DISABLE_DEPRECATED
struct qt_meta_stringdata_InfoReceiver_t {
    QByteArrayData data[9];
    char stringdata0[125];
};
#define QT_MOC_LITERAL(idx, ofs, len) \
    Q_STATIC_BYTE_ARRAY_DATA_HEADER_INITIALIZER_WITH_OFFSET(len, \
    qptrdiff(offsetof(qt_meta_stringdata_InfoReceiver_t, stringdata0) + ofs \
        - idx * sizeof(QByteArrayData)) \
    )
static const qt_meta_stringdata_InfoReceiver_t qt_meta_stringdata_InfoReceiver = {
    {
QT_MOC_LITERAL(0, 0, 12), // "InfoReceiver"
QT_MOC_LITERAL(1, 13, 11), // "onReadyRead"
QT_MOC_LITERAL(2, 25, 0), // ""
QT_MOC_LITERAL(3, 26, 15), // "readInformation"
QT_MOC_LITERAL(4, 42, 13), // "readImagePath"
QT_MOC_LITERAL(5, 56, 13), // "sendImagePath"
QT_MOC_LITERAL(6, 70, 4), // "path"
QT_MOC_LITERAL(7, 75, 24), // "readyReadImagePathChunks"
QT_MOC_LITERAL(8, 100, 24) // "onTcpClusterSocketClosed"

    },
    "InfoReceiver\0onReadyRead\0\0readInformation\0"
    "readImagePath\0sendImagePath\0path\0"
    "readyReadImagePathChunks\0"
    "onTcpClusterSocketClosed"
};
#undef QT_MOC_LITERAL

static const uint qt_meta_data_InfoReceiver[] = {

 // content:
       7,       // revision
       0,       // classname
       0,    0, // classinfo
       6,   14, // methods
       0,    0, // properties
       0,    0, // enums/sets
       0,    0, // constructors
       0,       // flags
       0,       // signalCount

 // slots: name, argc, parameters, tag, flags
       1,    0,   44,    2, 0x0a /* Public */,
       3,    0,   45,    2, 0x0a /* Public */,
       4,    0,   46,    2, 0x0a /* Public */,
       5,    1,   47,    2, 0x0a /* Public */,
       7,    0,   50,    2, 0x0a /* Public */,
       8,    0,   51,    2, 0x0a /* Public */,

 // slots: parameters
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void,
    QMetaType::Void, QMetaType::QString,    6,
    QMetaType::Void,
    QMetaType::Void,

       0        // eod
};

void InfoReceiver::qt_static_metacall(QObject *_o, QMetaObject::Call _c, int _id, void **_a)
{
    if (_c == QMetaObject::InvokeMetaMethod) {
        InfoReceiver *_t = static_cast<InfoReceiver *>(_o);
        Q_UNUSED(_t)
        switch (_id) {
        case 0: _t->onReadyRead(); break;
        case 1: _t->readInformation(); break;
        case 2: _t->readImagePath(); break;
        case 3: _t->sendImagePath((*reinterpret_cast< QString(*)>(_a[1]))); break;
        case 4: _t->readyReadImagePathChunks(); break;
        case 5: _t->onTcpClusterSocketClosed(); break;
        default: ;
        }
    }
}

const QMetaObject InfoReceiver::staticMetaObject = {
    { &QObject::staticMetaObject, qt_meta_stringdata_InfoReceiver.data,
      qt_meta_data_InfoReceiver,  qt_static_metacall, nullptr, nullptr}
};


const QMetaObject *InfoReceiver::metaObject() const
{
    return QObject::d_ptr->metaObject ? QObject::d_ptr->dynamicMetaObject() : &staticMetaObject;
}

void *InfoReceiver::qt_metacast(const char *_clname)
{
    if (!_clname) return nullptr;
    if (!strcmp(_clname, qt_meta_stringdata_InfoReceiver.stringdata0))
        return static_cast<void*>(this);
    return QObject::qt_metacast(_clname);
}

int InfoReceiver::qt_metacall(QMetaObject::Call _c, int _id, void **_a)
{
    _id = QObject::qt_metacall(_c, _id, _a);
    if (_id < 0)
        return _id;
    if (_c == QMetaObject::InvokeMetaMethod) {
        if (_id < 6)
            qt_static_metacall(this, _c, _id, _a);
        _id -= 6;
    } else if (_c == QMetaObject::RegisterMethodArgumentMetaType) {
        if (_id < 6)
            *reinterpret_cast<int*>(_a[0]) = -1;
        _id -= 6;
    }
    return _id;
}
QT_WARNING_POP
QT_END_MOC_NAMESPACE
