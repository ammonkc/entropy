<?php namespace Ammonkc\Entropy;

use Symfony\Component\Process\Process;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputArgument;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class RunCommand extends Command {

	/**
	 * Configure the command options.
	 *
	 * @return void
	 */
	protected function configure()
	{
		$this
			->setName('run')
			->setDescription('Run commands through the Entropy machine via SSH')
			->addArgument('ssh-command', InputArgument::REQUIRED, 'The command to pass through to the virtual machine.');
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
		chdir(__DIR__.'/../');

		$command = $input->getArgument('ssh-command');

		passthru('VAGRANT_DOTFILE_PATH="~/.entropy/.vagrant" vagrant ssh -c "'.$command.'"');
	}

}
