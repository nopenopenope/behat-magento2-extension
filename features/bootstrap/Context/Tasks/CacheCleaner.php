<?php

declare(strict_types=1);

namespace SEEC\Behat\Magento2Extension\Features\Bootstrap\Context\Tasks;

use Magento\Framework\App\Config;
use Magento\Framework\App\ObjectManager;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Finder\Finder;

final class CacheCleaner implements CacheCleanerInterface
{
    private MagentoPathProviderInterface $magentoPathProvider;

    private Filesystem $fileSystem;

    private Finder $finder;

    public function __construct(
        MagentoPathProviderInterface $magentoPathProvider = null,
        FileSystem $filesystem = null,
        Finder $finder = null,
    ) {
        $this->magentoPathProvider = $magentoPathProvider ?? new MagentoPathProvider();
        $this->fileSystem = $filesystem ?? new Filesystem();
        $this->finder = $finder ?? new Finder();
    }

    public function clean(bool $cleanObjectManager = true): void
    {
        $directory = $this->magentoPathProvider->getMagentoRootDirectory();
        $this->finder->directories();
        $cacheFolder = $this->finder->in(sprintf('%s/var/cache', $directory));
        $this->fileSystem->remove($cacheFolder);

        if ($cleanObjectManager) {
            /** @var Config $objectManager */
            $objectManager = ObjectManager::getInstance()->get(Config::class);
            $objectManager->clean();
        }
    }
}
