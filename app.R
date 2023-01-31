#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(stfun)

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Kindle 笔记导出"),

    # Sidebar with a slider input for number of bins
    sidebarLayout(
        sidebarPanel(
            fileInput("file", "上传 My Clippings.txt 文件", accept = ".txt"),
            checkboxGroupInput("paras", "请选择是否需要以下数据处理：",
                               c("删除重复笔记（Kindle 中起始位置相同的笔记将被删除）" = "distinct",
                                 "删除空白笔记（笔记为空白的将被删除" = "drop_na",
                                 "笔记分段处理（按照 Kindle 中的段落进行分段）" = "new_line",
                                 "Markdown输出添加时间" = "time"),
                               selected = c("distinct", "drop_na",
                                            "new_line", "time")),
            textInput("title", "选择需要导出的书名：（选填）", value = NULL,
                      placeholder = "建议输出 Markdown 时填写书名（支持正则表达式）。若为空，则默认导出全部笔记。"),
            actionButton("go", "开始处理！")
            ),

        # Show a plot of the generated distribution
        mainPanel(
            tags$div(
                tags$h3("Kindle 笔记处理流程："),
                tags$ol(
                    tags$li("将 Kindle 通过数据线连接至电脑；"),
                    tags$li("点击 Browse；"),
                    tags$li("选择 `Kindle/Documents` 文件夹下的 `My Clippings.txt` 文件，点击打开；"),
                    tags$li("选择需要进行的数据处理；"),
                    tags$li("输入需要导出的书名；"),
                    tags$li("点击「开始处理！」；"),
                    tags$li("下载所需要的文件。"),
                )
            ),
            downloadButton("xlsxoutput", "下载 xlsx 文件"),
            downloadButton("mdoutput", "下载 md 文件"),
            tags$br(),
            tags$br(),
            tags$p("Developed by ",
                   tags$a(href = "https://shitao.netlify.app/",
                          "Shitao Wu."))
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {
    data <- reactive({
        req(input$file)
        text <- kindle_read(input$file$datapath)
    })

    distinct <- reactive({
        if ("distinct" %in% input$paras) TRUE else FALSE
    })
    drop_na <- reactive({
        if ("distinct" %in% input$paras) TRUE else FALSE
    })
    new_line <- reactive({
        if ("new_line" %in% input$paras) TRUE else FALSE
    })
    time <- reactive({
        if ("time" %in% input$paras) TRUE else FALSE
    })

    title <- eventReactive(input$go, {
        if (input$title == "") NULL else input$title
    })

    output$xlsxoutput <- downloadHandler(
        filename = function() {
            paste(Sys.Date(), "-Kindle",".xlsx", sep = "")
        },
        content = function(file) {
            kindle_write_xlsx(data(), file,
                              distinct = distinct(),
                              drop_na = drop_na(),
                              new_line = new_line(),
                              title = title())
        }
    )

    output$mdoutput <- downloadHandler(
        filename = function() {
            paste(Sys.Date(), "-Kindle",".md", sep = "")
        },
        content = function(file) {
            kindle_write_md(data(), file,
                            distinct = distinct(),
                            drop_na = drop_na(),
                            new_line = new_line(),
                            time = time(),
                            title = title())
        }
    )

}

# Run the application
shinyApp(ui = ui, server = server)
