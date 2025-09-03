/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   client.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: avinals <avinals-@student.42madrid.com>    +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/07/11 12:31:40 by avinals           #+#    #+#             */
/*   Updated: 2025/07/12 17:58:55 by avinals          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "minitalk.h"

void	ft_send_signal(int pid, unsigned char character)
{
	int	i;

	i = 7;
	while (i >= 0)
	{
		if ((character >> i) & 1)
			kill(pid, SIGUSR1);
		else
			kill(pid, SIGUSR2);
		usleep(500);
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
		ft_printf("Error. Try: ./client <PID> <MESSAGE>\n");
		return (1);
	}
	pid = ft_atoi(av[1]);
	message = av[2];
	i = 0;
	while (message[i])
		ft_send_signal(pid, message[i++]);
	ft_send_signal(pid, '\0');
	return (0);
}
