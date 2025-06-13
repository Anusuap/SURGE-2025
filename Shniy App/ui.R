ui <- fluidPage(
  tags$head(
    tags$style(HTML(sprintf("
      body {
        background-color: %s;
        color: %s;
        font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
      }
      .landing-page {
        height: 100vh;
        background: linear-gradient(135deg, %s 40%%, %s 80%%);
        display: flex;
        flex-direction: column;
        justify-content: center;
        align-items: center;
        text-align: center;
        padding: 20px;
        border-radius: 15px;
        box-shadow: 0 0 25px %s88;
        margin-bottom: 20px;
      }
      .landing-page h1 {
        font-size: 48px;
        font-weight: 900;
        margin-bottom: 15px;
        text-shadow: 2px 2px 6px %sAA;
      }
      .landing-page p {
        font-size: 20px;
        font-weight: 600;
      }
      .thank-you {
        background: linear-gradient(135deg, %s 50%%, %s 90%%);
        color: %s;
        padding: 30px;
        border-radius: 12px;
        font-weight: 700;
        font-size: 24px;
        text-align: center;
        box-shadow: 0 0 15px %sAA;
      }
      label, h4 {
        color: %s;
        font-weight: 600;
      }
      .btn-success {
        background-color: %s !important;
        border-color: %s !important;
        color: #222222 !important;
        font-weight: 700 !important;
        box-shadow: 0 3px 10px %sAA !important;
      }
      .btn-success:hover {
        background-color: %s !important;
        border-color: %s !important;
      }
      .output-box {
        background-color: #F9F9F7;
        border: 1px solid %s;
        border-radius: 8px;
        padding: 15px;
        font-size: 16px;
        margin-top: 10px;
        color: #444444;
        font-weight: 600;
        box-shadow: inset 0 1px 4px %s33;
      }
    ",
                            bg_color, text_color, grad1, grad2, shadow, shadow, accent1, accent2, text_color,
                            shadow, text_color, btn_color, btn_color, shadow,
                            btn_hover, btn_hover, shadow, shadow
    )))
  ),
  
  tabsetPanel(
    tabPanel("Welcome",
             div(class = "landing-page",
                 h1("Welcome to Dirichlet Solver"),
                 p("Explore the solution to the Dirichlet problem on the unit disk."),
                 p("Simulate, visualize, and analyze with interactive tools."),
                 p("Enjoy the experience! ✨")
             )
    ),
    tabPanel("Simulation & Visualization",
             sidebarLayout(
               sidebarPanel(
                 h4("⚙️ Simulation Controls"),
                 selectInput("phi_fun", "Boundary Function φ(x, y):",
                             choices = c("x^2", "y^2", "x^2 + y^2", "sin(pi*x)", "cos(pi*y)",
                                         "sin(pi*x)*cos(pi*y)", "exp(x*y)", "x^3 - y^3"),
                             selected = "x^2"),
                 numericInput("n_sim", "Simulations per Grid Point:", 200, min = 50, step = 50),
                 sliderInput("x_range", "X-axis Range:", min = -1, max = 1, value = c(-1,1), step = 0.05),
                 sliderInput("y_range", "Y-axis Range:", min = -1, max = 1, value = c(-1,1), step = 0.05),
                 actionButton("simulate", "✨ Run Simulation", class = "btn btn-success")
               ),
               mainPanel(
                 h4("🧭 Estimated u(x, y)"),
                 div(verbatimTextOutput("click_value"), class = "output-box"),
                 tabsetPanel(
                   tabPanel("Heatmap",
                            plotOutput("heatmap", height = "600px", click = "plot_click")
                   ),
                   tabPanel("3D Surface",
                            plotlyOutput("plot3d", height = "650px")
                   )
                 )
               )
             )
    ),
    tabPanel("Thank You",
             div(class = "thank-you",
                 "🙏 Thank you for using the Dirichlet Problem Solver! 🌟"
             )
    )
  )
)
