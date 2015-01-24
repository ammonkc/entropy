<?php namespace Ammonkc\Entropy;

use Symfony\Component\Process\Process;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class ListCommand extends Command {

	/**
	 * Configure the command options.
	 *
	 * @return void
	 */
	protected function configure()
	{
		$this->setName('list')
                  ->setDescription('This command lists all the boxes that are installed into Vagrant');
	}

	/**
	 * Execute the command.
	 *
	 * @param  \Symfony\Component\Console\Input\InputInterface  $input
	 * @param  \Symfony\Component\Console\Output\OutputInterface  $output
	 * @return void
	 */
	public function execute(InputInterface $input, OutputInterface $output)
	{
		$process = new Process('vagrant box list | grep entropy', realpath(__DIR__.'/../'), $_ENV, null, null);

		$process->run(function($type, $line) use ($output)
		{
			$output->write($line);
		});
	}

}
