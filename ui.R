library(shinydashboard)

dashboardPage(
  
  # Header and Sidebar
  dashboardHeader(title = "Meetup Sign In"),
  dashboardSidebar(
    sidebarMenu(
      menuItem('Record Attendance', 
               tabName = "record_attendance",
               icon = icon("pencil")),
      menuItem("Review Attendance",
               tabName = "review_attendance",
               icon = icon("table"))
    ),
    textInput("api_key","API Key"),
    textInput("event_url", "Event URL"),
    selectInput("bossmode", "Boss Mode", c("Safe", "BE CAREFUL")),
    actionButton("mark_all_absent", "Mark Everyone Absent")
  ),
  
  # Body
  dashboardBody(
    tabItems(
      
      # Record Attendance
      tabItem(tabName = "record_attendance", 
        fluidRow(
          box(width = 12,
              status = "primary",
              solidHeader = T,
              title = "Record Attendance",
              uiOutput("select_member_name"),
              strong("RSVP Status: "), textOutput("get_rsvp"),
              strong("Attendance: "), textOutput("get_attendance"),
              selectInput("update_attendance","Update Attendance",
                          c("attended", "noshow", "absent")),
              actionButton("submit", "Submit")
          )
        )
      ),
      
      # Review Attendance
      tabItem(tabName = "review_attendance",
              fluidRow(valueBoxOutput("total_here"),
                       valueBoxOutput("total_rsvp"),
                       valueBoxOutput("total_other")),
              fluidRow(
                box(width = 12,
                    status = "warning",
                    solidHeader = T,
                    title = "Review Attendance",
                    DTOutput("attendance_table")
                )
              )
      )
    )
  )
)