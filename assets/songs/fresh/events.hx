function beatHit(curBeat)
{
	switch (curBeat)
	{
		case 16, 80:
			game.gfSpeed = 2;
		case 48, 112:
			game.gfSpeed = 1;
	}
}
