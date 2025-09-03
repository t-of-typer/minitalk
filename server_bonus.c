/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   server_bonus.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: avinals <avinals-@student.42madrid.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/12 12:32:57 by avinals           #+#    #+#             */
/*   Updated: 2025/07/13 18:30:00 by avinals          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"

static char	*g_buffer = NULL;

void	reset_buffer_state(int *buffer_len, int *buffer_size,
			int *bit_index, unsigned char *current_char)
{
	if (g_buffer)
		free(g_buffer);
	g_buffer = NULL;
	*buffer_len = 0;
	*buffer_size = 0;
	*bit_index = 0;
	*current_char = 0;
}

void	expand_buffer(int *buffer_size)
{
	char	*new_buffer;
	size_t	current_len;

	if (*buffer_size == 0)
		*buffer_size = 1024;
	else
		*buffer_size = *buffer_size * 2;
	new_buffer = malloc(*buffer_size);
	if (!new_buffer)
		return ;
	if (g_buffer)
	{
		current_len = ft_strlen(g_buffer);
		ft_memcpy(new_buffer, g_buffer, current_len);
		free(g_buffer);
	}
	g_buffer = new_buffer;
}

void	process_complete_char(unsigned char c, int *buffer_len,
		int *buffer_size)
{
	if (c == '\0')
	{
		if (g_buffer && *buffer_len > 0)
		{
			g_buffer[*buffer_len] = '\0';
			ft_printf("%s\n", g_buffer);
		}
		else
			ft_printf("\n");
		if (g_buffer)
			free(g_buffer);
		g_buffer = NULL;
		*buffer_len = 0;
		*buffer_size = 0;
	}
	else
	{
		if (*buffer_len >= *buffer_size)
			expand_buffer(buffer_size);
		if (g_buffer)
			g_buffer[(*buffer_len)++] = c;
	}
}

void	ft_handler(int signal, siginfo_t *info, void *context)
{
	static unsigned char	current_char = 0;
	static int				bit_index = 0;
	static int				buffer_len = 0;
	static int				buffer_size = 0;

	(void)context;
	if (signal == SIGUSR1)
		current_char = (current_char << 1) | 1;
	else
		current_char = current_char << 1;
	bit_index++;
	if (bit_index == 8)
	{
		if (g_buffer == NULL && current_char != '\0')
			expand_buffer(&buffer_size);
		if (g_buffer || current_char == '\0')
			process_complete_char(current_char, &buffer_len, &buffer_size);
		else
			reset_buffer_state(&buffer_len, &buffer_size,
				&bit_index, &current_char);
		bit_index = 0;
		current_char = 0;
	}
	kill(info->si_pid, SIGUSR1);
}

int	main(int ac, char **av)
{
	struct sigaction	sa;

	(void)av;
	if (ac != 1)
	{
		ft_printf("Error. Try: ./server_bonus\n");
		return (1);
	}
	ft_printf("PID: %d\n", getpid());
	ft_printf("Messages appear below\n");
	ft_printf("───────────────────────────────────────────────\n");
	sa.sa_sigaction = ft_handler;
	sigemptyset(&sa.sa_mask);
	sa.sa_flags = SA_SIGINFO;
	sigaction(SIGUSR1, &sa, NULL);
	sigaction(SIGUSR2, &sa, NULL);
	while (1)
		pause();
	return (0);
}
