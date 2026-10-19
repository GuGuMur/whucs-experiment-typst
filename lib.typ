// =============================================================================
// whucs-report
// 武汉大学计算机学院 本科生课程设计报告 Typst 主题
//
// 本主题依据《数字逻辑与数字电路课程设计报告模板.docx》逐项还原：
//   * A4，左右 3.175 cm，上下 2.54 cm
//   * 正文：宋体小四（12 pt），固定 1.5 倍行距，首行缩进 21 pt，两端对齐
//   * 章标题：黑体小二号（18 pt）加粗居中，段前 0.8 行、段后 0.5 行
//   * 节标题：黑体四号（14 pt）加粗；小节标题：黑体小四（12 pt）加粗
//   * 图表按章编号（图 1.1 / 表 2.1），表题在上、图题在下
//   * 公式按章编号，编号右对齐
//   * 封面、学术声明、摘要、目录、参考文献、附录、教师评语页
//
// 用法见 README.md 与 main.typ。
// =============================================================================

// -----------------------------------------------------------------------------
// 字体
// -----------------------------------------------------------------------------
// Typst 会按顺序为每个字符选择第一个包含该字形的字体：
// 西文/数字优先 Times New Roman，中文回退到宋体或思源宋体。
#let whucs-fonts = (
  body: (
    "Times New Roman",
    "SimSun",
    "Noto Serif CJK SC",
  ),
  sans: (
    "SimHei",
    "Noto Sans CJK SC",
  ),
  // 表题：中文黑体、数字/字母 Times New Roman（数字可加粗）
  caption-sans: (
    "Times New Roman",
    "SimHei",
    "Noto Sans CJK SC",
  ),
  mono: (
    "DejaVu Sans Mono",
    "Noto Sans Mono",
  ),
)

// -----------------------------------------------------------------------------
// 小工具
// -----------------------------------------------------------------------------
#let zh-digits = ("○", "一", "二", "三", "四", "五", "六", "七", "八", "九")

#let zh-digit(d) = zh-digits.at(d)

#let zh-year(year) = {
  str(year).clusters().map(c => zh-digit(int(c))).join()
}

#let zh-month(month) = {
  if month == 10 { "十" }
  else if month == 11 { "十一" }
  else if month == 12 { "十二" }
  else { zh-digit(month) }
}

/// 生成“二○二五年七月”形式的中文日期。
#let chinese-date(year: none, month: none) = {
  let today = datetime.today()
  let y = if year == none { today.year() } else { year }
  let m = if month == none { today.month() } else { month }
  [#zh-year(y)年#zh-month(m)月]
}

/// 把 auto / 字符串 / (年, 月) / (year: 年, month: 月) / datetime 统一成内容。
#let date-content(date) = {
  if date == none {
    none
  } else if date == auto {
    chinese-date()
  } else if type(date) == str {
    date
  } else if type(date) == array {
    chinese-date(year: date.at(0), month: date.at(1))
  } else if type(date) == dictionary {
    chinese-date(year: date.at("year"), month: date.at("month"))
  } else if type(date) == datetime {
    chinese-date(year: date.year(), month: date.month())
  } else {
    date
  }
}

/// 签名 / 日期用的下划线空白。
#let blank(width: 4cm, stroke: 0.5pt) = box(
  width: width,
  height: 1em,
  stroke: (bottom: stroke),
)

/// 宋体没有真正的粗体字重，用描边模拟 Word 的“加粗”。
#let song-strong(body, embolden: 0.3pt) = text(
  body,
  weight: "bold",
  stroke: embolden,
)

/// 用分隔符连接数组，元素可以是字符串或内容。
#let join-with(items, separator) = {
  for (i, item) in items.enumerate() {
    if i > 0 { separator }
    item
  }
}

/// keywords 既可以是数组，也可以是直接写好的内容。
#let keyword-list(keywords, separator: [；]) = {
  if type(keywords) == array {
    join-with(keywords, separator)
  } else {
    keywords
  }
}

// 正文是否已经开始。开始后页脚才显示页码。
#let body-started = state("whucs-report-body-started", false)

/// 正文入口：换页、重置页码、打开页脚页码。
#let main-matter(body) = {
  pagebreak(weak: true)
  body-started.update(true)
  counter(page).update(1)
  body
}

// -----------------------------------------------------------------------------
// 主体样式
// -----------------------------------------------------------------------------
/// 全局样式。推荐用法：
/// ```typst
/// #show: report.with(
///   page-numbering: "1",   // 需要页脚页码时
/// )
/// ```
#let report(
  body,
  paper: "a4",
  margin: (left: 3.175cm, right: 3.175cm, top: 2.54cm, bottom: 2.54cm),
  header: none,
  page-numbering: none,
  fonts: whucs-fonts,
  body-size: 12pt,
  body-leading: 15.1pt,
  first-line-indent: 21pt,
  par-spacing: auto,
  chapter-size: 18pt,
  section-size: 14pt,
  subsection-size: 12pt,
  chapter-above: 14.4pt,
  chapter-below: 14pt,
  section-above: 12pt,
  section-below: 26pt,
  subsection-above: 10pt,
  subsection-below: 26pt,
  heading-pagebreak: true,
  caption-size: 12pt,
  table-size: 10.5pt,
  table-inset: (x: 0.5em, y: 0.35em),
  figure-gap: 0.6em,
) = {
  let fonts = whucs-fonts + fonts
  let par-spacing = if par-spacing == auto { body-leading } else { par-spacing }

  // ---- 页面 -----------------------------------------------------------------
  set page(
    paper: paper,
    margin: margin,
    header: header,
    numbering: page-numbering,
    footer: context {
      if body-started.get() and page-numbering != none {
        align(center, text(font: fonts.body, size: 9pt)[
          #counter(page).display(page-numbering)
        ])
      }
    },
  )

  // ---- 正文 -----------------------------------------------------------------
  set text(
    font: fonts.body,
    size: body-size,
    lang: "zh",
    region: "cn",
    hyphenate: false,
    cjk-latin-spacing: none,
  )
  set par(
    justify: true,
    leading: body-leading,
    first-line-indent: (amount: first-line-indent, all: true),
    spacing: par-spacing,
  )

  // ---- 标题 -----------------------------------------------------------------
  set heading(numbering: "1.1.1", supplement: none)
  show heading: it => {
    let nums = counter(heading).at(it.location())
    let fmt = if it.level == 1 { "1" }
      else if it.level == 2 { "1.1" }
      else { "1.1.1" }
    let num = numbering(fmt, ..nums.slice(0, it.level))
    let prefix = if it.numbering == none {
      none
    } else {
      [#num#h(if it.level == 1 { 1em } else { 0.5em })]
    }

    if it.level == 1 {
      // 每章重新开始图、表、公式编号
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(math.equation).update(0)
      if heading-pagebreak { pagebreak(weak: true) }
      // 不编号的一级标题（结论/参考文献/附录/致谢）后面直接是文字，
      // 留出比正文行距更大的间距；编号章标题后面通常是节标题，由节标题段前距补足。
      let below = if it.numbering == none { 26pt } else { chapter-below }
      block(above: chapter-above, below: below, width: 100%)[
        #set par(
          first-line-indent: 0pt,
          leading: chapter-size * 1.2,
          justify: false,
        )
        #set align(center)
        #text(font: fonts.sans, size: chapter-size, weight: "bold")[
          #prefix#it.body
        ]
      ]
    } else if it.level == 2 {
      block(above: section-above, below: section-below, width: 100%)[
        #set par(
          first-line-indent: 0pt,
          leading: section-size * 1.2,
          justify: false,
        )
        #text(font: fonts.sans, size: section-size, weight: "bold")[
          #prefix#it.body
        ]
      ]
    } else {
      block(above: subsection-above, below: subsection-below, width: 100%)[
        #set par(
          first-line-indent: 0pt,
          leading: subsection-size * 1.2,
          justify: false,
        )
        #text(font: fonts.sans, size: subsection-size, weight: "bold")[
          #prefix#it.body
        ]
      ]
    }
  }

  // ---- 图 -------------------------------------------------------------------
  set figure(
    numbering: "1",
    supplement: [图],
    gap: figure-gap,
    placement: none,
  )
  show figure: it => block(above: 1.5em, below: 1.5em, width: 100%)[#it]
  show figure.where(kind: table): set figure(supplement: [表])
  show figure.where(kind: table): set figure.caption(position: top)

  show figure.caption: it => {
    set par(
      first-line-indent: 0pt,
      leading: 15pt,
      spacing: 0pt,
      justify: false,
    )
    set align(center)
    context {
      let loc = it.location()
      let nums = counter(heading).at(loc)
      let chap = if nums.len() > 0 { nums.first() } else { 0 }
      let n = it.counter.at(loc).first()
      let num = numbering("1.1", chap, n)
      if it.kind == table {
        set text(font: fonts.caption-sans, size: caption-size)
      } else {
        set text(font: fonts.body, size: caption-size)
      }
      [#it.supplement #text(weight: "bold")[#num]#h(0.5em)#it.body]
    }
  }

  // ---- 表 -------------------------------------------------------------------
  set table(stroke: 0.5pt, inset: table-inset, align: center)
  show table.cell: set text(size: table-size)
  show table.cell: set par(
    first-line-indent: 0pt,
    leading: 7.7pt,
    spacing: 0pt,
    justify: false,
  )

  // ---- 代码 -----------------------------------------------------------------
  show raw: set text(font: fonts.mono, size: 10.5pt)
  show raw.where(block: true): set par(
    first-line-indent: 0pt,
    leading: 13pt,
    spacing: 0pt,
  )

  // ---- 公式 -----------------------------------------------------------------
  show math.equation.where(block: true): it => block(
    above: 10pt,
    below: 10pt,
    width: 100%,
  )[#it]
  show math.equation: set text(font: "TeX Gyre Termes Math")
  set math.equation(numbering: n => context {
    let nums = counter(heading).get()
    let chap = if nums.len() > 0 { nums.first() } else { 0 }
    text(font: fonts.body, weight: "bold")[#numbering("(1.1)", chap, n)]
  })

  // ---- 交叉引用 -------------------------------------------------------------
  show ref: it => {
    let target = it.element
    if target != none and target.func() == figure {
      context {
        let loc = target.location()
        let nums = counter(heading).at(loc)
        let chap = if nums.len() > 0 { nums.first() } else { 0 }
        let n = target.counter.at(loc).first()
        link(loc, [#target.supplement #chap.#n])
      }
    } else if target != none and target.func() == math.equation {
      context {
        let loc = target.location()
        let nums = counter(heading).at(loc)
        let chap = if nums.len() > 0 { nums.first() } else { 0 }
        let n = counter(math.equation).at(loc).first()
        link(loc, [(#chap.#n)])
      }
    } else {
      it
    }
  }

  body
}

// -----------------------------------------------------------------------------
// 封面
// -----------------------------------------------------------------------------
/// 个人型实验报告封面。
///
/// 默认只在顶部居中显示 `assets/whu-emblem.png`（武汉大学圆形校徽），
/// 不再显示“武汉大学计算机学院”文字。传 `show-college: true` 可恢复该行，
/// 传 `logo: none` 可关闭校徽。
/// 所有字段均为命名参数，例如：
/// ```typst
/// #cover(
///   title: "数字频率计的设计与实现",
///   major: "计算机科学与技术",
///   course: "数字逻辑与数字电路课程设计",
///   supervisor: "张三",
///   student-id: "2023302111001",
///   student-name: "李四",
///   date: (2025, 7),
/// )
/// ```
#let cover(
  college: "武汉大学计算机学院",
  report-type: "本科生课程设计报告",
  title: "XXX设计与实现",
  major: "XXX XXX",
  course: "XXX XXX",
  supervisor: "XXX",
  student-id: "20XXXXXXXXX",
  student-name: "XXX",
  date: auto,
  logo: auto,
  logo-width: 3.8cm,
  show-college: false,
  extra: none,
  labels: (
    major: "专 业 名 称",
    course: "课 程 名 称",
    supervisor: "指 导 教 师",
    student-id: "学 生 学 号",
    student-name: "学 生 姓 名",
  ),
  fonts: whucs-fonts,
  embolden: 0.3pt,
  title-leading: 16.8pt,
  info-leading: 28.6pt,
  date-size: 18pt,
) = {
  let fonts = whucs-fonts + fonts
  let logo = if logo == auto {
    image("assets/whu-emblem.png", width: logo-width)
  } else {
    logo
  }

  pagebreak(weak: true)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  if logo != none {
    align(center, logo)
    v(0.5cm)
  }

  block(width: 100%)[
    #set par(leading: 15.8pt, first-line-indent: 0pt, justify: false)
    #align(center)[
      #if show-college {
        text(font: fonts.body, size: 26pt, weight: "bold", stroke: embolden)[
          #college
        ]
        linebreak()
      }
      #text(font: fonts.body, size: 26pt, weight: "bold", stroke: embolden)[
        #report-type
      ]
    ]
  ]

  v(1cm)

  align(center)[
    #set par(leading: title-leading, first-line-indent: 0pt, justify: false)
    #text(font: fonts.sans, size: 22pt, weight: "bold")[#title]
  ]

  v(1.8cm)

  block(width: 100%)[
    #set text(font: fonts.body, size: 15pt)
    #set par(first-line-indent: 0pt, spacing: 0pt, justify: false)
    #align(center)[
      #grid(
        columns: (auto, auto),
        column-gutter: 0.75em,
        row-gutter: info-leading,
        align: (right, left),
        [#labels.major：], [#major],
        [#labels.course：], [#course],
        [#labels.supervisor：], [#supervisor],
        [#labels.student-id：], [#student-id],
        [#labels.student-name：], [#student-name],
      )
    ]
  ]

  if extra != none {
    v(1cm)
    align(center, extra)
  }

  v(2.2cm)

  let d = date-content(date)
  if d != none {
    align(center, text(font: fonts.body, size: date-size)[#d])
  }

  pagebreak()
}

// -----------------------------------------------------------------------------
// 学术声明
// -----------------------------------------------------------------------------
#let default-statement = [
  本人呈交的实验报告，是在指导老师的指导下，独立进行实验工作所取得的成果，所有数据、图片资料真实可靠。尽我所知，除文中已经注明引用的内容外，本实验报告不包含他人享有著作权的内容。对本实验报告做出贡献的其他个人和集体，均已在文中以明确的方式标明。本实验报告的知识产权归属于培养单位。
]

#let declaration(
  title: [郑 重 声 明],
  statement: default-statement,
  signature: none,
  date: none,
  fonts: whucs-fonts,
  embolden: 0.3pt,
) = {
  let fonts = whucs-fonts + fonts
  pagebreak(weak: true)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  v(1.5cm)
  align(center, text(
    font: fonts.body,
    size: 22pt,
    weight: "bold",
    stroke: embolden,
  )[#title])

  v(1.2cm)

  block(inset: (left: 28pt))[
    #set text(font: fonts.body, size: 14pt)
    #set par(first-line-indent: (amount: 28pt, all: true), leading: 13.3pt, justify: true, spacing: 0pt)
    #parbreak()
    #statement
  ]

  v(3cm)

  block(inset: (left: 28pt))[
    #set text(font: fonts.body, size: 14pt)
    #set par(first-line-indent: 0pt, leading: 13.3pt, spacing: 0pt)
    本人签名：#if signature != none { signature } else { blank(width: 4cm) }
    #h(1.2cm)
    日期：#if date != none { date } else { blank(width: 4cm) }
  ]

  pagebreak()
}

// -----------------------------------------------------------------------------
// 摘要
// -----------------------------------------------------------------------------
#let abstract(
  body,
  title: [摘　要],
  keywords: (),
  keywords-label: [关键词：],
  fonts: whucs-fonts,
  title-size: 18pt,
  indent: 21pt,
  leading: 14.7pt,
) = {
  let fonts = whucs-fonts + fonts
  pagebreak(weak: true)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  align(center, text(font: fonts.sans, size: title-size)[#title])
  v(0.5cm)

  block(width: 100%)[
    #set text(font: fonts.body, size: 12pt)
    #set par(first-line-indent: (amount: indent, all: true), leading: leading, justify: true, spacing: leading)
    #parbreak()
    #body
  ]

  if keywords != () and keywords != none {
    v(0.8cm)
    block(width: 100%)[
      #set par(first-line-indent: 0pt, leading: 15.1pt, justify: false, spacing: 0pt)
      #text(font: fonts.sans, size: 12pt, weight: "bold")[#keywords-label]
      #text(font: fonts.body, size: 12pt)[#keyword-list(keywords)]
    ]
  }

  pagebreak()
}

/// 英文摘要（可选）。
#let abstract-en(
  body,
  title: [Abstract],
  keywords: (),
  keywords-label: [Key words: ],
  fonts: whucs-fonts,
  title-size: 18pt,
  leading: 15.1pt,
) = {
  let fonts = whucs-fonts + fonts
  pagebreak(weak: true)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  align(center, text(font: fonts.body, size: title-size, weight: "bold")[#title])
  v(0.5cm)

  block(width: 100%)[
    #set text(font: fonts.body, size: 12pt)
    #set par(first-line-indent: 0pt, leading: leading, justify: true, spacing: leading)
    #body
  ]

  if keywords != () and keywords != none {
    v(0.8cm)
    block(width: 100%)[
      #set par(first-line-indent: 0pt, leading: 15.1pt, justify: false, spacing: 0pt)
      #text(font: fonts.body, size: 12pt, weight: "bold")[#keywords-label]
      #text(font: fonts.body, size: 12pt)[#keyword-list(keywords, separator: [, ])]
    ]
  }

  pagebreak()
}

// -----------------------------------------------------------------------------
// 目录
// -----------------------------------------------------------------------------
#let toc(
  title: [目　录],
  depth: 2,
  indent: 0pt,
  fonts: whucs-fonts,
  title-size: 18pt,
  leading-1: 17.6pt,
  leading-2: 15.1pt,
) = {
  let fonts = whucs-fonts + fonts
  pagebreak(weak: true)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  align(center, text(
    font: fonts.sans,
    size: title-size,
    weight: "bold",
  )[#title])
  v(0.5cm)

  show outline.entry.where(level: 1): set text(
    font: fonts.sans,
    size: 14pt,
    weight: "bold",
  )
  show outline.entry.where(level: 1): set par(
    first-line-indent: 0pt,
    leading: leading-1,
    justify: false,
  )
  show outline.entry.where(level: 2): set text(
    font: fonts.body,
    size: 12pt,
  )
  show outline.entry.where(level: 2): set par(
    first-line-indent: 0pt,
    leading: leading-2,
    justify: false,
  )

  outline(title: none, depth: depth, indent: indent)
  pagebreak()
}

// -----------------------------------------------------------------------------
// 参考文献
// -----------------------------------------------------------------------------
#let references(
  sources,
  title: [参考文献],
  style: "gb-7714-2015-numeric",
  full: true,
  fonts: whucs-fonts,
) = {
  let fonts = whucs-fonts + fonts
  heading(level: 1, numbering: none, outlined: true)[#title]
  set text(font: fonts.body, size: 12pt)
  set par(
    first-line-indent: 0pt,
    justify: false,
    leading: 15.1pt,
    spacing: 15.1pt,
  )
  bibliography(sources, style: style, title: none, full: full)
}

// -----------------------------------------------------------------------------
// 结论 / 致谢 / 附录
// -----------------------------------------------------------------------------
/// 不编号的一级标题（会进入目录、另起一页）。
#let back-section(body, title) = {
  heading(level: 1, numbering: none, outlined: true)[#title]
  body
}

#let appendix(body, title: [附录]) = back-section(body, title)

#let acknowledgements(body, title: [致谢]) = back-section(body, title)

// -----------------------------------------------------------------------------
// 教师评语评分页
// -----------------------------------------------------------------------------
#let review(
  title: [教师评语评分],
  lines: 7,
  line-gap: 32pt,
  comment: none,
  score: none,
  reviewer: none,
  date: none,
  note: [（备注：对该实验报告给予优点和不足的评价，并给出百分之评分。）],
  note-size: 14pt,
  note-tracking: -0.2pt,
  fonts: whucs-fonts,
) = {
  let fonts = whucs-fonts + fonts
  pagebreak(weak: true)
  set par(first-line-indent: 0pt, justify: false, spacing: 0pt)

  align(center, text(font: fonts.body, size: 16pt)[#title])
  v(1cm)

  block(width: 100%)[
    #set text(font: fonts.body, size: 14pt)
    #set par(first-line-indent: 0pt, leading: 23pt, spacing: 23pt)
    评语：#if comment != none { comment }
  ]
  v(0.4cm)

  for _ in range(lines) {
    line(length: 100%, stroke: 0.5pt)
    v(line-gap)
  }

  v(0.8cm)
  block(width: 100%)[
    #set text(font: fonts.body, size: 14pt)
    评分：#if score != none { score } else { blank(width: 4cm) }
    #h(2cm)
    评阅人：#if reviewer != none { reviewer } else { blank(width: 4cm) }
  ]

  v(1.2cm)
  align(right)[
    #set text(font: fonts.body, size: 14pt)
    #if date != none { date } else { [年　　月　　日] }
  ]

  v(1fr)
  block(width: 100%)[
    #set text(font: fonts.body, size: note-size, tracking: note-tracking)
    #set par(first-line-indent: 0pt, spacing: 0pt)
    #parbreak()
    #note
  ]
}

// -----------------------------------------------------------------------------
// 表格与子图辅助
// -----------------------------------------------------------------------------
/// 全线表（普通表格）。用法与 table 相同：
/// ```typst
/// #grid-table(columns: 2, [类型], [描述], [CPU], [...])
/// ```
#let grid-table(..args) = table(
  stroke: 0.5pt,
  inset: (x: 0.5em, y: 0.35em),
  align: center,
  ..args,
)

/// 三线表。`rows` 为包含表头在内的总行数：
/// ```typst
/// #three-line-table(rows: 4, columns: 2, [表头], [表头], [a], [b], [c], [d])
/// ```
#let three-line-table(rows: 2, ..args) = table(
  stroke: none,
  table.hline(y: 0, stroke: 1.5pt),
  table.hline(y: 1, stroke: 0.5pt),
  table.hline(y: rows, stroke: 1.5pt),
  ..args,
)

/// 子图：只负责 (a) 这类子标题，不单独编号。
#let subfigure(body, caption: none, gap: 0.3em, fonts: whucs-fonts) = {
  let fonts = whucs-fonts + fonts
  block(width: 100%)[
    #align(center, body)
    #if caption != none {
      v(gap)
      align(center, text(font: fonts.sans, size: 12pt)[#caption])
    }
  ]
}
