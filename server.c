/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: avinals <avinals-@student.42madrid.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/11 12:31:43 by avinals           #+#    #+#             */
/*   Updated: 2025/07/13 18:00:00 by avinals          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"

static char	g_message[4096];

void	print_message(void)
{
	ft_printf("%s\n", g_message);
}

void	reset_message(void)
{
	int	i;

	i = 0;
	while (i < 4096)
	{
		g_message[i] = '\0';
		i++;
	}
}

void	add_char_to_message(unsigned char c)
{
	static int	len = 0;

	if (c == '\0')
	{
		g_message[len] = '\0';
		print_message();
		reset_message();
		len = 0;
		return ;
	}
	if (len < 4095)
	{
		g_message[len] = c;
		len++;
	}
}

void	ft_handler(int signal)
{
	static unsigned char	current_char = 0;
	static int				bit_index = 0;

	if (signal == SIGUSR1)
		current_char = (current_char << 1) | 1;
	else
		current_char = current_char << 1;
	bit_index++;
	if (bit_index == 8)
	{
		add_char_to_message(current_char);
		bit_index = 0;
		current_char = 0;
	}
}

int	main(int ac, char **av)
{
	(void)av;
	if (ac != 1)
	{
		ft_printf("Error. Try: ./server\n");
		return (1);
	}
	ft_printf("PID: %d\n", getpid());
	ft_printf("Messages appear below\n");
	ft_printf("───────────────────────────────────────────────\n");
	reset_message();
	signal(SIGUSR1, ft_handler);
	signal(SIGUSR2, ft_handler);
	while (1)
		pause();
	return (0);
}
