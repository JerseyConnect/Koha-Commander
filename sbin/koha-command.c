#define REAL_PATH "KOHA_COMMANDER_PATH/koha-command.pl"

main(ac, av)
	char **av;
	{
	execv(REAL_PATH, av);
}