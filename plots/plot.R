library(dplyr)
library(lubridate)
library(ggplot2)
library(knitr)

# Rscript scaling.R metric experiment data 
args <- commandArgs(trailingOnly = TRUE)

metric <- args[1]
experiment <- args[2]
data <- args[3]

prometheus_rate <- function(df) {
  df <- df %>% arrange(timestamp)
  
  df$timestamp <- as.POSIXct(df$timestamp, origin = "1970-01-01")
  
  result_df <- df %>%
    mutate(time = timestamp,
           end = lead(timestamp),
           first_value = value,
           last_value = lead(value)) %>%
    
    filter(!is.na(end)) %>%
    
    mutate(absolute_value = last_value - first_value,
           diff_time = as.numeric(difftime(end, timestamp, units = "secs"))) %>%
    
    mutate(value = absolute_value / diff_time)
  
  return(result_df)
}

exp_df <- read.csv(data) %>%
  select(where(~ any(!is.na(.))))

hpa_spec_max_replicas_df <- exp_df %>%
  filter(name == "kube_horizontalpodautoscaler_spec_max_replicas") %>%
  filter(grepl(pattern = paste0(experiment, "*"), horizontalpodautoscaler)) %>%
  select(where(~ !all(. == ""))) %>%
  mutate(timestamp = as.POSIXct(.$timestamp, origin = "1970-01-01")) %>%
  mutate(timestamp_rounded = round_date(timestamp, unit = "minute"))

hpa_spec_target_metric_df <- exp_df %>%
  filter(name == "kube_horizontalpodautoscaler_spec_target_metric") %>%
  filter(grepl(pattern = paste0(experiment, "*"), horizontalpodautoscaler)) %>%
  select(where(~ !all(. == ""))) %>%
  mutate(timestamp = as.POSIXct(.$timestamp, origin = "1970-01-01")) %>%
  mutate(timestamp_rounded = round_date(timestamp, unit = "minute"))

hpa_spec_min_replicas_df <- exp_df %>%
  filter(name == "kube_horizontalpodautoscaler_spec_min_replicas") %>%
  filter(grepl(pattern = paste0(experiment, "*"), horizontalpodautoscaler)) %>%
  select(where(~ !all(. == ""))) %>%
  mutate(timestamp = as.POSIXct(.$timestamp, origin = "1970-01-01")) %>%
  mutate(timestamp_rounded = round_date(timestamp, unit = "minute"))

hpa_status_desired_replicas_df <- exp_df %>%
  filter(name == "kube_horizontalpodautoscaler_status_desired_replicas") %>%
  filter(grepl(pattern = paste0(experiment, "*"), horizontalpodautoscaler)) %>%
  select(where(~ !all(. == ""))) %>%
  mutate(timestamp = as.POSIXct(.$timestamp, origin = "1970-01-01")) %>%
  mutate(timestamp_rounded = round_date(timestamp, unit = "minute"))


if (metric == "memory") {
  container_resource_request_df <- exp_df %>%
    filter(name == "kube_pod_container_resource_requests") %>%
    filter(grepl(pattern = paste0(experiment, "*"), pod)) %>%
    filter(unit == "byte") %>%
    select(where(~ !all(. == ""))) %>%
    mutate(timestamp = as.POSIXct(.$timestamp, origin = "1970-01-01")) %>%
    mutate(timestamp_rounded = round_date(timestamp, unit = "minute"))
  
  metric_df <- exp_df %>%
    filter(name == "container_memory_usage_bytes") %>%
    filter(grepl(pattern = paste0(experiment, "*"), container)) %>%
    select(where(~ !all(. == ""))) %>%
    mutate(timestamp = as.POSIXct(.$timestamp, origin = "1970-01-01")) %>%
    mutate(timestamp_rounded = round_date(timestamp, unit = "minute")) %>%
    left_join(container_resource_request_df, by = c("timestamp_rounded", "pod", "container"), suffix = c("_usage", "_request")) %>%
    na.omit() %>%
    mutate(container_usage = value_usage/value_request)
  
} else if (metric == "cpu"){
  container_resource_request_df <- exp_df %>%
    filter(name == "kube_pod_container_resource_requests") %>%
    filter(grepl(pattern = paste0(experiment, "*"), pod)) %>%
    filter(unit == "core") %>%
    select(where(~ !all(. == ""))) %>%
    mutate(timestamp = as.POSIXct(.$timestamp, origin = "1970-01-01")) %>%
    mutate(timestamp_rounded = round_date(timestamp, unit = "minute"))
  
  print(exp_df %>%
    filter(name == "container_cpu_usage_seconds_total") %>%
    filter(grepl(pattern = paste0(experiment, "*"), container)) %>%
    select(where(~ !all(. == "")))) 

  metric_df <- exp_df %>%
    filter(name == "container_cpu_usage_seconds_total") %>%
    filter(grepl(pattern = paste0(experiment, "*"), container)) %>%
    select(where(~ !all(. == ""))) %>%
    group_by(pod, container, namespace, id, name) %>%
    do(prometheus_rate(.)) %>%
    ungroup() %>%
    mutate(timestamp_rounded = round_date(end, unit = "minute")) %>%
    left_join(container_resource_request_df, by = c("timestamp_rounded", "pod", "container"), suffix = c("_usage", "_request")) %>%
    na.omit() %>%
    mutate(container_usage = value_usage/value_request)
}

pod_usage_df <- metric_df %>%
  group_by(timestamp_rounded, pod) %>%
  mutate(
    max_usage = max(container_usage),
    average_usage = sum(container_usage)/length(container_usage),
    pod_usage = sum(value_usage)/sum(value_request)) %>%
  select(timestamp_rounded, pod_usage, average_usage, max_usage) %>%
  left_join(hpa_status_desired_replicas_df, by=c("timestamp_rounded")) %>%
  mutate(replicas = value) %>%
  select(timestamp_rounded, max_usage, average_usage, pod_usage, replicas)


# Converter o dataframe para Markdown e salvar
markdown_content <- kable(pod_usage_df, format = "markdown")
writeLines(markdown_content, paste0(experiment,".md"))

