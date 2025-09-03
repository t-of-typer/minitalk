# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: avinals <avinals-@student.42madrid.com>    +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2025/04/07 11:58:01 by avinals           #+#    #+#              #
#    Updated: 2025/04/07 11:58:39 by avinals          ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

SERVER_NAME		= server
CLIENT_NAME		= client
SERVER_B_NAME	= server_b
CLIENT_B_NAME	= client_b

LIBFT_DIR		= ./Libft
OBJ_DIR			= obj/

LIBFT			= $(LIBFT_DIR)/libft.a

SERVER_SRC		= server.c
CLIENT_SRC		= client.c
SERVER_B_SRC	= server_bonus.c
CLIENT_B_SRC	= client_bonus.c

SERVER_OBJ		= $(OBJ_DIR)server.o
CLIENT_OBJ		= $(OBJ_DIR)client.o
SERVER_B_OBJ	= $(OBJ_DIR)server_bonus.o
CLIENT_B_OBJ	= $(OBJ_DIR)client_bonus.o

# Compiler and flags
CC				= cc
CFLAGS			= -Wall -Werror -Wextra
INCLUDES		= -I. -I$(LIBFT_DIR)
RM				= rm -f

# Colors
GREEN			= \033[0;32m
RED				= \033[0;31m
RESET			= \033[0m

# Rules
all:	$(SERVER_NAME) $(CLIENT_NAME)

$(SERVER_NAME): $(LIBFT) $(SERVER_OBJ)
	@echo "$(GREEN)Linking $(SERVER_NAME)...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) $(SERVER_OBJ) $(LIBFT) -o $(SERVER_NAME)
	@echo "$(GREEN)$(SERVER_NAME) created successfully!$(RESET)"

$(CLIENT_NAME): $(LIBFT) $(CLIENT_OBJ)
	@echo "$(GREEN)Linking $(CLIENT_NAME)...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) $(CLIENT_OBJ) $(LIBFT) -o $(CLIENT_NAME)
	@echo "$(GREEN)$(CLIENT_NAME) created successfully!$(RESET)"

$(LIBFT):
	@echo "$(GREEN)Building libft...$(RESET)"
	@make -s -C $(LIBFT_DIR)

$(OBJ_DIR)%.o: %.c
	@mkdir -p $(dir $@)
	@echo "Compiling $<..."
	@$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

bonus: $(SERVER_B_NAME) $(CLIENT_B_NAME)

$(SERVER_B_NAME): $(LIBFT) $(SERVER_B_OBJ)
	@echo "$(GREEN)Linking $(SERVER_B_NAME)...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) $(SERVER_B_OBJ) $(LIBFT) -o $(SERVER_B_NAME)
	@echo "$(GREEN)$(SERVER_B_NAME) created successfully!$(RESET)"

$(CLIENT_B_NAME): $(LIBFT) $(CLIENT_B_OBJ)
	@echo "$(GREEN)Linking $(CLIENT_B_NAME)...$(RESET)"
	@$(CC) $(CFLAGS) $(INCLUDES) $(CLIENT_B_OBJ) $(LIBFT) -o $(CLIENT_B_NAME)
	@echo "$(GREEN)$(CLIENT_B_NAME) created successfully!$(RESET)"

clean:
	@echo "$(RED)Cleaning object files...$(RESET)"
	@$(RM) -r $(OBJ_DIR)
	@make clean -s -C $(LIBFT_DIR)

fclean: clean
	@echo "$(RED)Cleaning executables...$(RESET)"
	@$(RM) $(SERVER_NAME) $(CLIENT_NAME) $(SERVER_B_NAME) $(CLIENT_B_NAME)
	@make fclean -s -C $(LIBFT_DIR)

re: fclean all

.PHONY: all clean fclean re bonus