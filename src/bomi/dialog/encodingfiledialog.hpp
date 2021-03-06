#ifndef ENCODINGFILEDIALOG_HPP
#define ENCODINGFILEDIALOG_HPP

#include <QFileDialog>

class EncodingComboBox;

class EncodingFileDialog : public QFileDialog {
    Q_OBJECT
public:
    static auto getOpenFileName(QWidget *parent = 0,
                                const QString &caption = QString(),
                                const QString &dir = QString(),
                                const QString &filter = QString(),
                                QString *enc = 0) -> QString;
    static auto getOpenFileNames(QWidget *parent = 0,
                                 const QString &caption = QString(),
                                 const QString &dir = QString(),
                                 const QString &filter = QString(),
                                 QString *enc = 0,
                                 FileMode = ExistingFiles) -> QStringList;
private:
    EncodingFileDialog(QWidget *parent = 0,
                       const QString &caption = QString(),
                       const QString &directory = QString(),
                       const QString &filter = QString(),
                       const QString &encoding = QString());
    auto setEncoding(const QString &encoding) -> void;
    auto encoding() const -> QString;
    EncodingComboBox *combo = nullptr;
};

#endif // ENCODINGFILEDIALOG_HPP
