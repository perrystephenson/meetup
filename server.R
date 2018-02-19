server <- function(input, output) {
  
  output$select_member_name <- renderUI({
    event_url <- strsplit(input$event_url, "/")[[1]][[4]]
    event_id <- strsplit(input$event_url, "/")[[1]][[6]]
    rsvp <- get_event_rsvps(event_url, event_id, input$api_key)
    member_names <- rsvp$member_id
    names(member_names) <- rsvp$member_name
    selectInput("member_name", "Member Name", member_names, selected = "")
  })

  observeEvent(input$submit, {
    event_url <- strsplit(input$event_url, "/")[[1]][[4]]
    event_id <- strsplit(input$event_url, "/")[[1]][[6]]
    post_event_attendance(event_url, event_id, input$member_name, 
                          input$update_attendance, input$api_key)
  })
  
  output$get_rsvp <- renderText({
    event_url <- strsplit(input$event_url, "/")[[1]][[4]]
    event_id <- strsplit(input$event_url, "/")[[1]][[6]]
    rsvp <- get_event_rsvps(event_url, event_id, input$api_key)
    rsvp$response[which(rsvp$member_id == input$member_name)]
  })
  
  output$get_attendance <- renderText({
    invalidate_i <- input$submit
    event_url <- strsplit(input$event_url, "/")[[1]][[4]]
    event_id <- strsplit(input$event_url, "/")[[1]][[6]]
    attendance <- get_event_attendees(event_url, event_id, input$api_key, filter = "relevant")
    attendance$status[which(attendance$id == input$member_name)]
  })
  
  attendance_react <- reactive({
    invalidate_i <- input$submit
    event_url <- strsplit(input$event_url, "/")[[1]][[4]]
    event_id <- strsplit(input$event_url, "/")[[1]][[6]]
    attendance <- get_event_attendees(event_url, event_id, input$api_key, filter = "relevant")
    rsvp <- get_event_rsvps(event_url, event_id, input$api_key)
    left_join(rsvp, attendance, by = c("member_id" = "id")) %>% 
      select("member_id", "name", "response", "status")
  })
  
  output$attendance_table <- renderDataTable(attendance_react())
  
  output$total_here <- renderValueBox({
    tmp <- attendance_react()
    tmp <- tmp[tmp$status == "attended" & !is.na(tmp$status),]
    valueBox(nrow(tmp), "Total", icon = icon("users"), color = "green")
  })
  
  output$total_rsvp <- renderValueBox({
    tmp <- attendance_react()
    tmp <- tmp[tmp$status == "attended" & !is.na(tmp$status) & tmp$response == "yes",]
    valueBox(nrow(tmp), "RSVP", icon = icon("check"), color = "purple")
  })
  
  output$total_other <- renderValueBox({
    tmp <- attendance_react()
    tmp <- tmp[tmp$status == "attended" & !is.na(tmp$status) & tmp$response != "yes",]
    valueBox(nrow(tmp), "Other", icon = icon("question"), color = "orange")
  })
  
  observeEvent(input$mark_all_absent, {
    if(input$bossmode == "BE CAREFUL") {
      
      event_url <- strsplit(input$event_url, "/")[[1]][[4]]
      event_id <- strsplit(input$event_url, "/")[[1]][[6]]
      attendance <- get_event_attendees(event_url, event_id, input$api_key, filter = "relevant")
      ids <- attendance$id[attendance$id > 0]
      post_event_attendance(event_url, event_id, ids, "noshow", input$api_key)
      
    } else {
      message("CRISIS AVERTED")
    }
  })
  
}