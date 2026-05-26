import AppKit
import Foundation

private let cutPathsPasteboardType = NSPasteboard.PasteboardType("com.local.NewFileApp.cutPaths")

enum NewFileKind: String {
    case plainText
    case markdown
    case richText
    case csv
    case json
    case html
    case css
    case word
    case pdf
    case powerpoint
    case excel
    case javascript
    case python
    case swift
    case shell

    var baseName: String {
        switch self {
        case .plainText: return "新建文本文档"
        case .markdown: return "新建Markdown"
        case .richText: return "新建富文本"
        case .csv: return "新建CSV"
        case .json: return "新建JSON"
        case .html: return "新建HTML"
        case .css: return "新建CSS"
        case .word: return "新建Word文档"
        case .pdf: return "新建PDF"
        case .powerpoint: return "新建PowerPoint"
        case .excel: return "新建Excel表格"
        case .javascript: return "新建JavaScript"
        case .python: return "新建Python"
        case .swift: return "新建Swift"
        case .shell: return "新建Shell脚本"
        }
    }

    var fileExtension: String {
        switch self {
        case .plainText: return "txt"
        case .markdown: return "md"
        case .richText: return "rtf"
        case .csv: return "csv"
        case .json: return "json"
        case .html: return "html"
        case .css: return "css"
        case .word: return "docx"
        case .pdf: return "pdf"
        case .powerpoint: return "pptx"
        case .excel: return "xlsx"
        case .javascript: return "js"
        case .python: return "py"
        case .swift: return "swift"
        case .shell: return "sh"
        }
    }

    var contents: Data {
        let value: String

        switch self {
        case .plainText:
            value = ""
        case .markdown:
            value = "# Untitled\n"
        case .richText:
            value = "{\\rtf1\\ansi\\deff0\\n}"
        case .csv:
            value = "name,value\n"
        case .json:
            value = "{\n  \n}\n"
        case .html:
            value = """
            <!doctype html>
            <html lang="zh-CN">
            <head>
              <meta charset="utf-8">
              <meta name="viewport" content="width=device-width, initial-scale=1">
              <title>Untitled</title>
            </head>
            <body>
            </body>
            </html>
            """
        case .css:
            value = """
            :root {
              color-scheme: light dark;
            }

            body {
              margin: 0;
            }
            """
        case .word:
            return TemplateData.wordDocument
        case .pdf:
            return TemplateData.pdfDocument
        case .powerpoint:
            return TemplateData.powerPointPresentation
        case .excel:
            return TemplateData.excelWorkbook
        case .javascript:
            value = "console.log('Hello');\n"
        case .python:
            value = "#!/usr/bin/env python3\n\n"
        case .swift:
            value = "import Foundation\n\n"
        case .shell:
            value = "#!/bin/zsh\n\n"
        }

        return Data(value.utf8)
    }

    var isExecutable: Bool {
        self == .shell || self == .python
    }
}

private enum TemplateData {
    static let wordDocument = data(fromBase64: """
    UEsDBBQAAAAIAAAAIVzJTxqw6wAAAK4BAAATAAAAW0NvbnRlbnRfVHlwZXNdLnhtbH1QvU7DMBDeeQrLK4odGBBCSTrwMwJDeYCTfUks7LPlc0v79jht6YAK4933q69b7YIXW8zsIvXyRrVSIJloHU29/Fi/NPdScAGy4CNhL/fIcjVcdet9QhZVTNzLuZT0oDWbGQOwigmpImPMAUo986QTmE+YUN+27Z02kQpSacriIYfuCUfY+CKed/V9LJLRsxSPR+KS1UtIyTsDpeJ6S/ZXSnNKUFV54PDsEl9XgtQXExbk74CT7q0uk51F8Q65vEKoLP0Vs9U2mk2oSvW/zYWecRydwbN+cUs5GmSukwevzkgARz/99WHu4RtQSwMEFAAAAAgAAAAhXLmBRHGwAAAAKgEAAAsAAABfcmVscy8ucmVsc43POw7CMAwG4J1TRN5pWgaEUJMuCKkrKgeIEjeNaB5KwqO3JwMDIAZG278/y233sDO5YUzGOwZNVQNBJ70yTjM4D8f1DkjKwikxe4cMFkzQ8VV7wlnkspMmExIpiEsMppzDntIkJ7QiVT6gK5PRRytyKaOmQciL0Eg3db2l8d0A/mGSXjGIvWqADEvAf2w/jkbiwcurRZd/nPhKFFlEjZnB3UdF1atdFRYob+nHi/wJUEsDBBQAAAAIAAAAIVypO6lQzAAAACkBAAARAAAAd29yZC9kb2N1bWVudC54bWxFT8FOwzAMvfMVke8sKUxVqdbuthsSEvABWeK1lZo4SjzK+Hpc0NSL7fee9Z59OH6HWX1hLhPFDqqdAYXRkZ/i0MHnx+mxAVXYRm9nitjBDQsc+4fD0npy14CRlTjE0i4djMyp1bq4EYMtO0oYRbtQDpYF5kEvlH3K5LAUCQizfjKm1sFOEXqxPJO/rT3ptRZ0/Jb/8PD+o5Y1oqpeTA0yjzLXzXMD+n/h1WZhmZLw+71ZV/I0jLzBMzFT2PCMl7sqHnrL0/dD9PZk/wtQSwECFAMUAAAACAAAACFcyU8asOsAAACuAQAAEwAAAAAAAAAAAAAAgAEAAAAAW0NvbnRlbnRfVHlwZXNdLnhtbFBLAQIUAxQAAAAIAAAAIVy5gURxsAAAACoBAAALAAAAAAAAAAAAAACAARwBAABfcmVscy8ucmVsc1BLAQIUAxQAAAAIAAAAIVypO6lQzAAAACkBAAARAAAAAAAAAAAAAACAAfUBAAB3b3JkL2RvY3VtZW50LnhtbFBLBQYAAAAAAwADALkAAADwAgAAAAA=
    """)

    static let pdfDocument = data(fromBase64: """
    JVBERi0xLjQKMSAwIG9iago8PCAvVHlwZSAvQ2F0YWxvZyAvUGFnZXMgMiAwIFIgPj4KZW5kb2JqCjIgMCBvYmoKPDwgL1R5cGUgL1BhZ2VzIC9LaWRzIFszIDAgUl0gL0NvdW50IDEgPj4KZW5kb2JqCjMgMCBvYmoKPDwgL1R5cGUgL1BhZ2UgL1BhcmVudCAyIDAgUiAvTWVkaWFCb3ggWzAgMCA1OTUgODQyXSAvQ29udGVudHMgNCAwIFIgPj4KZW5kb2JqCjQgMCBvYmoKPDwgL0xlbmd0aCAwID4+CnN0cmVhbQoKZW5kc3RyZWFtCmVuZG9iagp4cmVmCjAgNQowMDAwMDAwMDAwIDY1NTM1IGYgCjAwMDAwMDAwMDkgMDAwMDAgbiAKMDAwMDAwMDA1OCAwMDAwMCBuIAowMDAwMDAwMTE1IDAwMDAwIG4gCjAwMDAwMDAyMDIgMDAwMDAgbiAKdHJhaWxlcgo8PCAvU2l6ZSA1IC9Sb290IDEgMCBSID4+CnN0YXJ0eHJlZgoyNTEKJSVFT0YK
    """)

    static let powerPointPresentation = data(fromBase64: """
    UEsDBBQAAAAIABJTr1wF6S4UbQEAAGwGAAATAAAAW0NvbnRlbnRfVHlwZXNdLnhtbLWVy07DMBBF
    93yF5S1K3LJACCXtgseKRyXKBxhn0lo4tmW7pfl7JkkLoaKVUcnG0njm3nsyCyebbipF1uC8NDqn
    43RECWhhCqkXOX2d3ydXlPjAdcGV0ZDTGjydTs6yeW3BExRrn9NlCPaaMS+WUHGfGgsaO6VxFQ9Y
    ugWzXLzzBbCL0eiSCaMD6JCExoNOzgjJbqHkKxXI3QY7HYsD5Sm56WabuJxya5UUPGCfrXWxF5Rs
    Q1JUtjN+Ka0/xwHKDoU0zcMZ39JnXJGTBZAZd+GJVzjICiNmzljPUJIeN/oF1pSlFIAeqwolKTRM
    BRSJRUtwQUKf/Gi8MA7+nr9bVqOOD7U2MOvAY0rrfPJ3980q9aNMKy51JE+7iSFgWuMIiLWEj0Eg
    vowjIAJ/U/ASagX/jtGzjgHBhwC6c3wySWsTEeoVXj5yH/A16xenE+ztoucdi/XAa7MKvl8Mg9V5
    x2JtgYZB2UFkrP1ZTD4BUEsDBBQAAAAIABJTr1zyGI3f6wAAAFoCAAALAAAAX3JlbHMvLnJlbHOt
    ksFKAzEQhu99ijD3brYVRGSzvYjQm0h9gCGZ3Q3dJEMySvv2hoJixWoPHjP558s3Q7rNIczqjXLx
    KRpYNS0oijY5H0cDL7vH5R2oIhgdzimSgSMV2PSL7plmlNpTJs9FVUgsBiYRvte62IkCliYxxXoz
    pBxQ6jGPmtHucSS9bttbnb8yoF8odYZVW2cgb90K1O7IdA0+DYO39JDsa6AoP7zyLVHJmEcSA8yi
    OVOpxVO6qWTQF53W1ztdHlkHEnQoqG3KtORcu7P4uuFPLZfsUy2XU+IPp5v/3BMdhKIj97sVMn9I
    dfrsS/TvUEsDBBQAAAAIABJTr1z3OZDMOgEAAIkCAAARAAAAZG9jUHJvcHMvY29yZS54bWydkk9v
    wiAYh+9+ioZ7C63RLE1bsz/xNJclc9myG4FXJQNKgK367UfRdjN6WtID5ffw8L5AtdgrmXyDdaLV
    NcozghLQrOVCb2v0ul6mNyhxnmpOZauhRgdwaNFMKmZK1lp4tq0B6wW4JIi0K5mp0c57U2Ls2A4U
    dVkgdAg3rVXUh1+7xYayT7oFXBAyxwo85dRT3AtTMxrRScnZqDRfVkYBZxgkKNDe4TzL8S/rwSp3
    dUFM/pBK+IOBq+gQjvTeiRHsui7rphEN9ef4ffX4EltNhe6PigFqJklScVZ64SU0FR6Hp3lmgfrW
    Nk/QLYWEW2MiM0z3VDhgSZ1fhavYCOB3hzP4Mj2aY49HD/AkVF0eexySt+n9w3qJmoIU85TM0ny2
    JqSM30dfwtn6M6c6bfVv6SAIjwdfvJ7mB1BLAwQUAAAACAASU69cV9jQCLABAAChAwAAEAAAAGRv
    Y1Byb3BzL2FwcC54bWydU01v4yAUvOdXIE7dQ4LTrapVhKlWqaI99CNS096peY7RYkDAuk1//QKO
    LVvtqT4N88bzhgfQm/dWoQ6cl0aXeL0qMAJdGSH1scTPh93yF0Y+cC24MhpKfAKPb9iC7p2x4IIE
    j6KD9iVuQrAbQnzVQMv9KpZ1rNTGtTzEpTsSU9eygltT/WtBB3JZFNcE3gNoAWJpR0PcO2668F1T
    YaqUz78cTjb6sQVC9Le1SlY8xH2yB3jbSQWRomTKJ93egY9GmdjlPuxRL33lADR6aswburja/PxB
    yRfC9P+TkgI8W1NyRol8MCGigpIeJOqPFAL0WRMrs3US3N9vlbS5NsDsX3EF27g7VnPlIbYZiWwL
    PJ3dnkvnGe3CpoMqGIe8/Iind4nRK/eQxlLijjvJdcC9rF9krKwPjvVRKBmJDKe6KZZXacs9mAvJ
    GCLiWbyU9yCDAv9Y77kLXwReTwPnGHgS8VO4oc3cNfXZmtZyfYq1ASX2Tuq//tkezC0PMAx0TuaZ
    N9yBiHdsnPlI5JnHdE6lv7YN10cQg+xz4XwTX/oHx9bXqyJ++RYO3CJdreEtsP9QSwMEFAAAAAgA
    ElOvXJD/hoZKAQAAkgIAABQAAABwcHQvcHJlc2VudGF0aW9uLnhtbI2SwW7CMAyG7zxFlPtIC6Xr
    KloOm5AmbRMa7AGyxqWV0qSKA2t5+qVAWdl24Bb79//FjjNfNJUkezBYapVQf+xRAirTolTbhH5s
    lncRJWi5ElxqBQltAekiHc3ruDaAoCy3zkkcRWHME1pYW8eMYVZAxXGsa1BOy7WpuHWh2TJh+Jej
    V5JNPC9kFS8VPfvNLX6d52UGTzrbVe76E8SAPPaBRVljT6tvoQ2nuG4J+R7Wu08Eu9TKonscmo4I
    cZOjFK8cLZhn8YI2vc6QUiR04gf3QTQNA/d6Ju4yTvEpS+fsj/3CHNJ6ziwcACY/gF/W9YFkTUIf
    /CDwPLfCrE1oGM2iY2Db2i0OMwOggmbqICef0hbw7LwUd84e0xcKyPlO2g00dm1bCV3aCbwTViuT
    nk7vK0Mk777Nobh7fDv2einpQOw/Upcd7iD9BlBLAwQUAAAACAASU69c+G/ODvUAAABbAwAAHwAA
    AHBwdC9fcmVscy9wcmVzZW50YXRpb24ueG1sLnJlbHOt081OxCAUBeD9PAW5e0s7/sSY0tkYk1mY
    GB0fAMttS4YC4eJo314W2rQTTV10yeFy+BJCufvsDTthIO2sgCLLgaGtndK2FfB6eLi4BUZRWiWN
    syhgQIJdtSmf0ciYzlCnPbFUYklAF6O/45zqDntJmfNo007jQi9jWoaWe1kfZYt8m+c3PEw7oNow
    NqtleyUg7FUB7DB4/E+9axpd472r33u08ZdbOBmt8FFSxJBqZWgxCpiEs4kiS/3A/5RtV5edmb7T
    Jcflmg4fkJ6CSy8yWsZowXG1puOk8ePMMUYLjus1HVG+GXyJg8GJZBL+WEo++xPVF1BLAwQUAAAA
    CAASU69c8Z0zOx4BAABDAgAAFQAAAHBwdC9zbGlkZXMvc2xpZGUxLnhtbI1Ru27DMAzc8xWC9oZp
    h6IwYmdIH1ObAEk/QJDp2IBeoFTX+fvSj8BtkSGLRJ54Rx613nTWiBYpNt7l8n65kgKd9mXjTrn8
    PL7ePUkRk3KlMt5hLs8Y5aZYrEMWTSmY7GKmclmnFDKAqGu0Ki59QMdvlSerEqd0gpLUN4taAw+r
    1SNY1Tg58ekWvq+qRuOz118WXRpFCI1KPHismxAvauEWtUAYWWZg/xmpWAjB5vTBlEVvMhwJsY9c
    +0bhEPbUJ/qj3ZNoSt6YFE5ZXoyE6WEqg5E0BPCPfrqEKusqsv3N9kSXS17/uT+hx7BLQo+gnlFd
    767U6vrlSjVcGsCvpjDbgsnpZNrQuwq7dhiMF5eQtgMU+ONGG3PJYtBh7g9QSwMEFAAAAAgAElOv
    XIAy1Ki4AAAAOgEAACAAAABwcHQvc2xpZGVzL19yZWxzL3NsaWRlMS54bWwucmVsc42PwQrCMBBE
    735F2LtJ60FETHsRQfAk+gFLsm2DbRKyUezfm6MFDx53duYNc2jf0yhelNgFr6GWFQjyJljnew33
    22m9A8EZvcUxeNIwE0PbrA5XGjGXDA8usigQzxqGnONeKTYDTcgyRPLl04U0YS5n6lVE88Ce1Kaq
    tip9M6BZCbHAirPVkM62BnGbI/2DD13nDB2DeU7k848WxaOzdME5PHPBYuopa5DyW1+YalkqQJXF
    ajG5+QBQSwMEFAAAAAgAElOvXKbTRGk4AQAAdgIAACEAAABwcHQvc2xpZGVMYXlvdXRzL3NsaWRl
    TGF5b3V0MS54bWyNUstuwyAQvOcrEPeGpIeqsmJH6vPSNpGSfgDF69gqLy3Etf++gG2ljXLIxSzD
    zLCzeLXulCQtoGuMzulyvqAEtDBlow85/dy/3NxT4jzXJZdGQ057cHRdzFY2c7J84705ehIstMt4
    TmvvbcaYEzUo7ubGgg5nlUHFfdjigZXIf4K1kux2sbhjijeajnq8Rm+qqhHwZMRRgfaDCYLkPrTv
    6sa6yc1e42YRXLBJ6v8t+d6GsF+S629KEg3bACxpMSMkhBc7WRLNVcAeEqmIE7F7BIiVbl/R7uwW
    40Z8tFskTRnlo4ay8WCksUGUCnYmP0wlz7oKVVzDFEiX0/BWffyyiEHniRhAcUJFvbnAFfXzBTab
    LmB/LmWnWGyIPU1A4ju3mzY1FubrAR8TZMP7DjFOlFnymX6Y4hdQSwMEFAAAAAgAElOvXLSVk4q3
    AAAAOgEAACwAAABwcHQvc2xpZGVMYXlvdXRzL19yZWxzL3NsaWRlTGF5b3V0MS54bWwucmVsc42P
    sQ7CMAxEd74i8k7SMiCESFkQEgMLKh9gJW4b0SZRHBD9ezJSiYHR57t3usPxPY3iRYld8BpqWYEg
    b4J1vtdwb8/rHQjO6C2OwZOGmRiOzepwoxFzyfDgIosC8axhyDnulWIz0IQsQyRfPl1IE+Zypl5F
    NA/sSW2qaqvSNwOalRALrLhYDeliaxDtHOkffOg6Z+gUzHMin3+0KB6dpStyplSwmHrKGqT81hem
    WpYKUGWxWkxuPlBLAwQUAAAACAASU69cnwM/S80BAADbAwAAIQAAAHBwdC9zbGlkZU1hc3RlcnMv
    c2xpZGVNYXN0ZXIxLnhtbI2TwVLkIBCG7/MUFHdlJhNHTU3iwV13rdLVqnEfgAGSUBKgAMfk7bdJ
    gqOuBy+h+6P7h+4m26u+U+ggnJdGl3h1usRIaGa41E2J/z7dnFxg5APVnCqjRYkH4fFVtdjawit+
    T30QDoGE9gUtcRuCLQjxrBUd9afGCg17tXEdDeC6hnBHX0G6UyRbLjeko1LjOd99J9/UtWTih2Ev
    ndBhEnFC0QDX9620PqnZ76hZJzzIjNkfrlQtEIIS2U7xCtZ9M30fXbWlhTdK8hup1OhEdXGtHDpQ
    VeJ9s8Kk2pJPUaKuBQt3PsS9pESSsLdPToho6cMvZ3c27sLpfw6PDkkOY8FI0w66H7XHjTmMTEmj
    QT6lN8mkRV+7Lq7QPdSXGGY8xC8Zr9YHxCbIjpS1D1/EsvbnF9EkHUDeHUqOZZG5kXNPlbunFkGj
    SqwCVBZ6sPgzWPsmiyyLLIsMLMoYTAgiZiORLJG3mHUi60TyRPJEzhI5S2STyAajVkn9DO8mLhjV
    Rv2eQLKg2KkGePp3dDAv4ZbDTKuPZJxYtsrP84v1Jr/EyBWRuFs+PY3/0ifN0O/CoISPakEGJUZ3
    HPDe8OHomdAKl1zyLnExa09/ZfUPUEsDBBQAAAAIABJTr1zgLeiqzgAAAMQBAAAsAAAAcHB0L3Ns
    aWRlTWFzdGVycy9fcmVscy9zbGlkZU1hc3RlcjEueG1sLnJlbHOtkM9KxDAQxu/7FGHuJu0eRKTp
    XkRY2JOsDzAk0zbYJiEzu9i3NyjIFhQ8eBmYP9/v+5ju8L7M6kqFQ4oWWt2AouiSD3G08Hp+vnsA
    xYLR45wiWViJ4dDvuheaUaqGp5BZVUhkC5NIfjSG3UQLsk6ZYt0MqSwotS2jyejecCSzb5p7U24Z
    0O+U2mDV0VsoR9+COq+Z/oJPwxAcPSV3WSjKDy6G5+DphGu6SMViGUksaH073xy1ulqA+TXc/j/D
    SdXSJtbn5Kt+J+nM5vn9B1BLAwQUAAAACAASU69cVb6fMesBAADaBQAAFAAAAHBwdC90aGVtZS90
    aGVtZTEueG1srZTNbqMwFIX3fQrL+6mBAk2iQBUY0CxGmkXTB3CNSZgaO8JW07z9GJOAiZPNqF4A
    vvc75/rnivXLV8vAJ+1kI3gC/UcPAsqJqBq+S+DbtvyxgEAqzCvMBKcJPFEJX9KHNV6pPW0p0HIu
    VziBe6UOK4Qk0WEsH8WBcp2rRddipafdDlUdPmrblqHA82LU4oZDwHGrXf/UdUMo2PaWMH0A4OJf
    MP3gSvYxEyWseyWmsq2EQ94Q1Yef6pc8yZx14BOzBOqylThu6ZeCgGGpdCKBnhkQpWs0ipi6o7V0
    pRlnXS+wSwdG3u3eR71fhsvnn2OZYCjjckVR5IU/2gaWLSZEn4HvSMJy4WcXawsaPt0SuRd54ZwP
    Jv7J4ZdZlkXLGf808aHDL7w43AQzPpz4yF1/tsnzeMZHEx87fPm8jMM5H1vHtGcN/3BE/SWP1zUi
    tWC/buILjS8uXTFSQ/chq/3GhqwFVzc7Uuda/Fd0pQbMpWPVcKBOB1pjorlN12DWF8Iriq34ECLy
    KoSu7NqGf6v3ZIfsTU37bO9us24Ye1UnRn9LsxopWFOVOmgmRjSe72GvP881LQ65LozPZ+CoOzIK
    Ivj/JRg/v2xnWteUqDuRaapzg+Usi27p33flt5zItQ+ybsH8JJHzlxxD6T9QSwMEFAAAAAgAElOv
    XKo06S94AAAAjwAAABEAAABwcHQvcHJlc1Byb3BzLnhtbE2MMQ7CMAwAvxJ5pwkMCEVNu3VmgAdY
    rWkjJU4UWwh+T0bG0+lunD85mTc1iYUDnAcHhngtW+Q9wPOxnG5gRJE3TIUpwJcE5mmsvjYSYkXt
    4b2ZvmHxNcChWr21sh6UUYZSibt7lZZRO7bd/pc52YtzV5sxMtjpB1BLAwQUAAAACAASU69c35j4
    tngAAACHAAAAEQAAAHBwdC92aWV3UHJvcHMueG1sDY0xDsIwDAC/EnmnDgwIRU27MTPAA6LWtJES
    J4qtAr8n4+l0unH+5mQOahILezgPFgzxUtbIm4fX8366gRENvIZUmDz8SGCexuqOSJ9HMz1ncdXD
    rlodoiw75SBDqcTdvUvLQTu2DWsjIdagfZUTXqy9Yg6RAac/UEsDBBQAAAAIABJTr1ySTOZroQAA
    ALQAAAATAAAAcHB0L3RhYmxlU3R5bGVzLnhtbA3MSQ6CMBhA4as0/76UoSASCmGQlTv1ABXKkHQg
    tFGJ8e6yfHnJl5cfJdFLbHYxmkHg+YCE7s2w6InB497hFJB1XA9cGi0Y7MJCWeQ8c095c7sUV+vQ
    YWibcQazc2tGiO1nobj1zCr08UazKe6O3CYybPx92EqS0PcToviiAQ1iZPCNmzCMKa3w6XJJMI1o
    iGufpjiN67Y5d23QRNUPSPEHUEsBAhQDFAAAAAgAElOvXAXpLhRtAQAAbAYAABMAAAAAAAAAAAAA
    AIABAAAAAFtDb250ZW50X1R5cGVzXS54bWxQSwECFAMUAAAACAASU69c8hiN3+sAAABaAgAACwAA
    AAAAAAAAAAAAgAGeAQAAX3JlbHMvLnJlbHNQSwECFAMUAAAACAASU69c9zmQzDoBAACJAgAAEQAA
    AAAAAAAAAAAAgAGyAgAAZG9jUHJvcHMvY29yZS54bWxQSwECFAMUAAAACAASU69cV9jQCLABAACh
    AwAAEAAAAAAAAAAAAAAAgAEbBAAAZG9jUHJvcHMvYXBwLnhtbFBLAQIUAxQAAAAIABJTr1yQ/4aG
    SgEAAJICAAAUAAAAAAAAAAAAAACAAfkFAABwcHQvcHJlc2VudGF0aW9uLnhtbFBLAQIUAxQAAAAI
    ABJTr1z4b84O9QAAAFsDAAAfAAAAAAAAAAAAAACAAXUHAABwcHQvX3JlbHMvcHJlc2VudGF0aW9u
    LnhtbC5yZWxzUEsBAhQDFAAAAAgAElOvXPGdMzseAQAAQwIAABUAAAAAAAAAAAAAAIABpwgAAHBw
    dC9zbGlkZXMvc2xpZGUxLnhtbFBLAQIUAxQAAAAIABJTr1yAMtSouAAAADoBAAAgAAAAAAAAAAAA
    AACAAfgJAABwcHQvc2xpZGVzL19yZWxzL3NsaWRlMS54bWwucmVsc1BLAQIUAxQAAAAIABJTr1ym
    00RpOAEAAHYCAAAhAAAAAAAAAAAAAACAAe4KAABwcHQvc2xpZGVMYXlvdXRzL3NsaWRlTGF5b3V0
    MS54bWxQSwECFAMUAAAACAASU69ctJWTircAAAA6AQAALAAAAAAAAAAAAAAAgAFlDAAAcHB0L3Ns
    aWRlTGF5b3V0cy9fcmVscy9zbGlkZUxheW91dDEueG1sLnJlbHNQSwECFAMUAAAACAASU69cnwM/
    S80BAADbAwAAIQAAAAAAAAAAAAAAgAFmDQAAcHB0L3NsaWRlTWFzdGVycy9zbGlkZU1hc3RlcjEu
    eG1sUEsBAhQDFAAAAAgAElOvXOAt6KrOAAAAxAEAACwAAAAAAAAAAAAAAIABcg8AAHBwdC9zbGlk
    ZU1hc3RlcnMvX3JlbHMvc2xpZGVNYXN0ZXIxLnhtbC5yZWxzUEsBAhQDFAAAAAgAElOvXFW+nzHr
    AQAA2gUAABQAAAAAAAAAAAAAAIABihAAAHBwdC90aGVtZS90aGVtZTEueG1sUEsBAhQDFAAAAAgA
    ElOvXKo06S94AAAAjwAAABEAAAAAAAAAAAAAAIABpxIAAHBwdC9wcmVzUHJvcHMueG1sUEsBAhQD
    FAAAAAgAElOvXN+Y+LZ4AAAAhwAAABEAAAAAAAAAAAAAAIABThMAAHBwdC92aWV3UHJvcHMueG1s
    UEsBAhQDFAAAAAgAElOvXJJM5muhAAAAtAAAABMAAAAAAAAAAAAAAIAB9RMAAHBwdC90YWJsZVN0
    eWxlcy54bWxQSwUGAAAAABAAEABqBAAAxxQAAAAA
    """)

    static let excelWorkbook = data(fromBase64: """
    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
    """)

    private static func data(fromBase64 base64: String) -> Data {
        let compact = base64.components(separatedBy: .whitespacesAndNewlines).joined()
        return Data(base64Encoded: compact) ?? Data()
    }
}

enum NewFileCreator {
    static func handle(_ url: URL) {
        writeLog("handle url: \(url.absoluteString)")

        guard
            url.scheme == "newfileapp",
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let host = url.host
        else {
            showAlert("新建文件请求无效。")
            return
        }

        switch host {
        case "create":
            guard
                let type = components.queryItems?.first(where: { $0.name == "type" })?.value,
                let path = components.queryItems?.first(where: { $0.name == "path" })?.value,
                let kind = NewFileKind(rawValue: type)
            else {
                showAlert("新建文件请求无效。")
                return
            }

            create(kind, in: URL(fileURLWithPath: path, isDirectory: true))
        case "folder":
            guard let path = components.queryItems?.first(where: { $0.name == "path" })?.value else {
                showAlert("新建文件夹请求无效。")
                return
            }

            createFolder(in: URL(fileURLWithPath: path, isDirectory: true))
        case "pasteCut":
            guard let path = components.queryItems?.first(where: { $0.name == "path" })?.value else {
                showAlert("粘贴请求无效。")
                return
            }

            pasteCutItems(to: URL(fileURLWithPath: path, isDirectory: true))
        case "trash":
            let paths = components.queryItems?
                .filter { $0.name == "path" }
                .compactMap(\.value) ?? []

            guard !paths.isEmpty else {
                showAlert("移到废纸篓请求无效。")
                return
            }

            trashItems(paths.map { URL(fileURLWithPath: $0) })
        case "terminal":
            guard let path = components.queryItems?.first(where: { $0.name == "path" })?.value else {
                showAlert("打开终端请求无效。")
                return
            }

            openTerminal(in: URL(fileURLWithPath: path, isDirectory: true))
        default:
            showAlert("请求无效：\(host)")
        }
    }

    static func createFolder(in directoryURL: URL) {
        writeLog("create folder in \(directoryURL.path)")

        do {
            let destinationURL = uniqueFolderURL(in: directoryURL)
            try FileManager.default.createDirectory(at: destinationURL, withIntermediateDirectories: false)
            writeLog("created folder \(destinationURL.path)")
            NSWorkspace.shared.activateFileViewerSelecting([destinationURL])
        } catch {
            writeLog("create folder failed \(error.localizedDescription)")
            showAlert("创建文件夹失败：\(error.localizedDescription)\n\n目录：\(directoryURL.path)")
        }
    }

    static func create(_ kind: NewFileKind, in directoryURL: URL) {
        writeLog("create \(kind.rawValue) in \(directoryURL.path)")

        do {
            let destinationURL = uniqueURL(for: kind, in: directoryURL)
            try kind.contents.write(to: destinationURL, options: .withoutOverwriting)
            writeLog("created \(destinationURL.path)")

            if kind.isExecutable {
                try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: destinationURL.path)
            }

            NSWorkspace.shared.activateFileViewerSelecting([destinationURL])
        } catch {
            writeLog("failed \(error.localizedDescription)")
            showAlert("创建文件失败：\(error.localizedDescription)\n\n目录：\(directoryURL.path)")
        }
    }

    static func pasteCutItems(to directoryURL: URL) {
        writeLog("paste cut to \(directoryURL.path)")

        let pasteboard = NSPasteboard.general
        guard let value = pasteboard.string(forType: cutPathsPasteboardType) else {
            writeLog("paste cut failed: no cut paths")
            showAlert("没有可粘贴的剪切项目。")
            return
        }

        let sourceURLs = value
            .split(separator: "\n")
            .map { URL(fileURLWithPath: String($0)) }
            .filter { FileManager.default.fileExists(atPath: $0.path) }

        guard !sourceURLs.isEmpty else {
            pasteboard.clearContents()
            showAlert("剪切项目不存在，无法粘贴。")
            return
        }

        var movedURLs: [URL] = []
        var failures: [String] = []

        for sourceURL in sourceURLs {
            do {
                if sourceURL.deletingLastPathComponent().standardizedFileURL == directoryURL.standardizedFileURL {
                    movedURLs.append(sourceURL)
                    continue
                }

                if isDirectory(sourceURL),
                   directoryURL.standardizedFileURL.path.hasPrefix(sourceURL.standardizedFileURL.path + "/") {
                    failures.append("\(sourceURL.lastPathComponent)：不能移动到自身内部")
                    continue
                }

                let destinationURL = uniqueURL(forMoving: sourceURL, in: directoryURL)
                try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
                movedURLs.append(destinationURL)
                writeLog("moved \(sourceURL.path) to \(destinationURL.path)")
            } catch {
                failures.append("\(sourceURL.lastPathComponent)：\(error.localizedDescription)")
                writeLog("move failed \(sourceURL.path): \(error.localizedDescription)")
            }
        }

        if !movedURLs.isEmpty {
            pasteboard.clearContents()
            NSWorkspace.shared.activateFileViewerSelecting(movedURLs)
        }

        if !failures.isEmpty {
            showAlert("部分项目移动失败：\n\n\(failures.joined(separator: "\n"))")
        }
    }

    static func trashItems(_ itemURLs: [URL]) {
        writeLog("trash \(itemURLs.map { $0.path })")

        var failures: [String] = []

        for itemURL in itemURLs {
            do {
                var resultingURL: NSURL?
                try FileManager.default.trashItem(at: itemURL, resultingItemURL: &resultingURL)
                writeLog("trashed \(itemURL.path)")
            } catch {
                failures.append("\(itemURL.lastPathComponent)：\(error.localizedDescription)")
                writeLog("trash failed \(itemURL.path): \(error.localizedDescription)")
            }
        }

        if !failures.isEmpty {
            showAlert("部分项目移到废纸篓失败：\n\n\(failures.joined(separator: "\n"))")
        }
    }

    static func openTerminal(in directoryURL: URL) {
        writeLog("open terminal in \(directoryURL.path)")

        do {
            let commandURL = FileManager.default.temporaryDirectory
                .appendingPathComponent("NewFileApp-\(UUID().uuidString)")
                .appendingPathExtension("command")
            let script = """
            #!/bin/zsh
            cd \(shellSingleQuoted(directoryURL.path)) || exit 1
            rm -- "$0"
            exec /bin/zsh -l
            """

            try Data(script.utf8).write(to: commandURL, options: .atomic)
            try FileManager.default.setAttributes([.posixPermissions: 0o700], ofItemAtPath: commandURL.path)

            if NSWorkspace.shared.open(commandURL) {
                writeLog("terminal command opened at \(directoryURL.path)")
            } else {
                writeLog("open terminal failed: NSWorkspace.open returned false")
                showAlert("打开终端失败。\n\n目录：\(directoryURL.path)")
            }
        } catch {
            writeLog("open terminal failed: \(error.localizedDescription)")
            showAlert("打开终端失败。\n\n目录：\(directoryURL.path)")
        }
    }

    private static func uniqueFolderURL(in directoryURL: URL) -> URL {
        uniqueURL(baseName: "新建文件夹", fileExtension: nil, in: directoryURL)
    }

    private static func uniqueURL(for kind: NewFileKind, in directoryURL: URL) -> URL {
        uniqueURL(baseName: kind.baseName, fileExtension: kind.fileExtension, in: directoryURL)
    }

    private static func uniqueURL(forMoving sourceURL: URL, in directoryURL: URL) -> URL {
        let baseName = sourceURL.deletingPathExtension().lastPathComponent
        let fileExtension = sourceURL.pathExtension.isEmpty ? nil : sourceURL.pathExtension
        return uniqueURL(baseName: baseName, fileExtension: fileExtension, in: directoryURL)
    }

    private static func uniqueURL(baseName: String, fileExtension: String?, in directoryURL: URL) -> URL {
        let fileManager = FileManager.default
        var preferredURL = directoryURL.appendingPathComponent(baseName)

        if let fileExtension {
            preferredURL = preferredURL.appendingPathExtension(fileExtension)
        }

        guard fileManager.fileExists(atPath: preferredURL.path) else {
            return preferredURL
        }

        for index in 2...999 {
            var url = directoryURL.appendingPathComponent("\(baseName) \(index)")

            if let fileExtension {
                url = url.appendingPathExtension(fileExtension)
            }

            if !fileManager.fileExists(atPath: url.path) {
                return url
            }
        }

        var fallbackURL = directoryURL.appendingPathComponent("\(baseName) \(UUID().uuidString)")

        if let fileExtension {
            fallbackURL = fallbackURL.appendingPathExtension(fileExtension)
        }

        return fallbackURL
    }

    private static func isDirectory(_ url: URL) -> Bool {
        (try? url.resourceValues(forKeys: [.isDirectoryKey]).isDirectory) == true
    }

    private static func shellSingleQuoted(_ value: String) -> String {
        "'\(value.replacingOccurrences(of: "'", with: "'\\''"))'"
    }

    private static func showAlert(_ message: String) {
        let alert = NSAlert()
        alert.messageText = "访达右键新建文件"
        alert.informativeText = message
        alert.alertStyle = .warning
        alert.addButton(withTitle: "好")
        alert.runModal()
    }

    private static func writeLog(_ message: String) {
        let line = "[\(Date())] \(message)\n"
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Logs/NewFileApp.log")

        if let data = line.data(using: .utf8) {
            if FileManager.default.fileExists(atPath: url.path),
               let handle = try? FileHandle(forWritingTo: url) {
                try? handle.seekToEnd()
                try? handle.write(contentsOf: data)
                try? handle.close()
            } else {
                try? data.write(to: url)
            }
        }
    }
}
