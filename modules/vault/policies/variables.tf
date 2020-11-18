variable "policies" {
  type = map(object({
    compartment_id = string  
    description    = string,
    statements     = list(string)
  }))
}