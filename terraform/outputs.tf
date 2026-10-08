output "server_public_ip" {
  description = "Public IP of the chatbot server"
  value       = aws_instance.chatbot.public_ip
}
