/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client_bonus.c                                     :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: avinals <avinals-@student.42madrid.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/12 12:32:55 by avinals           #+#    #+#             */
/*   Updated: 2025/07/12 17:59:03 by avinals          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"

static int	g_received = 0;

void	sigconfirm(int signal)
{
	(void)signal;
	g_received = 1;
}

void	ft_send_signal(int pid, unsigned char character)
{
	int	i;

	i = 7;
	while (i >= 0)
	{
		g_received = 0;
		if ((character >> i) & 1)
			kill(pid, SIGUSR1);
		else
			kill(pid, SIGUSR2);
		while (!g_received)
			usleep(50);
		i--;
	}
}

int	main(int ac, char **av)
{
	int			pid;
	const char	*message;
	int			i;

	if (ac != 3)
	{
		ft_printf("Error. Try: ./client_bonus <PID> <MESSAGE>\n");
		return (1);
	}
	pid = ft_atoi(av[1]);
	message = av[2];
	signal(SIGUSR1, sigconfirm);
	signal(SIGUSR2, sigconfirm);
	i = 0;
	while (message[i])
		ft_send_signal(pid, message[i++]);
	ft_send_signal(pid, '\0');
	ft_printf("Message sent successfully!\n");
	return (0);
}
