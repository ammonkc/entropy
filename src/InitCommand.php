<?php

namespace Ammonkc\Entropy;

use InvalidArgumentException;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;

class InitCommand extends Command
{
    /**
     * Configure the command options.
     *
     * @return void
     */
    protected function configure()
    {
        $this->setName('init')->setDescription('Create a stub Entropy.yaml file');
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
        if (is_dir(entropy_path())) {
            throw new \InvalidArgumentException("Entropy has already been initialized.");
        }

        mkdir(entropy_path());

        copy(__DIR__.'/stubs/Entropy.yaml', entropy_path().'/Entropy.yaml');
        copy(__DIR__.'/stubs/after.sh', entropy_path().'/after.sh');
        copy(__DIR__.'/stubs/aliases', entropy_path().'/aliases');

        $output->writeln('<comment>Creating Entropy.yaml file...</comment> <info>✔</info>');
        $output->writeln('<comment>Entropy.yaml file created at:</comment> '.entropy_path().'/Entropy.yaml');
    }
}
